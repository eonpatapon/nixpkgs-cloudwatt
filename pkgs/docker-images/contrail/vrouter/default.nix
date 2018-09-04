# This builds a Contrail Vrouter Docker image for testing purposes
# only. It spawns a QEMU VM inside the container. The VM loads the
# Contrail vrouter kernel modules and starts the Contrail Vrouter
# Agent. For the dataplane, a VDE network is created. We want to be
# able to spawn several compute nodes from one image. At runtime,
# compute nodes uses their MAC address (provided by QEMU) to provision
# their dataplane IP address and hostname.

{ pkgs, contrailPkgs, contrailPath, configFiles, waitFor }:

with import (pkgs.path + "/nixos/lib/testing.nix") { system = builtins.currentSystem; };

let
  contrailVrouterAgentFilepath = "/run/contrail-vrouter-agent.conf";

  config = { pkgs, lib, config, ... }: {
    imports = [ (contrailPath + "/modules/compute-node.nix") ];
    config = {
      _module.args = { inherit contrailPkgs; isContrailMaster=false; isContrail32=true; };

      networking.firewall.enable = false;
      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";
      services.openssh.extraConfig = "PermitEmptyPasswords yes";
      users.extraUsers.root.password = "";

      virtualisation.graphics = false;
      virtualisation.memorySize = 1024;

      environment.etc."contrail/vnc_api_lib.ini".source = configFiles.contrail.vncApiLibVrouter;

      contrail.vrouterAgent = {
        enable = true;
        configurationFilepath = contrailVrouterAgentFilepath;
        provisionning = false;
        vhostInterface = "eth2";
      };

      # We use the MAC address to set the hostname and the IP address
      # on the contrail inteface. We use this hack since it hard to
      # pass values through QEMU.  The compute node uses its hostname
      # to subscribe to the controller IFMAP and its IP to set the
      # nexthop.
      systemd.services.configureContrailInterface = {
        serviceConfig.Type = "oneshot";
        serviceConfig.RemainAfterExit = true;
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        before = [ "configureVhostInterface.service" "contrailVrouterAgent.service"];
        path = [ pkgs.iproute pkgs.nettools ];
        script = ''
          set -x
          # The last part of the MAC address is used to define the IP
          # address and the hostname
          CONTRAIL_INTERFACE=eth2
          NUMBER=$(ip l show $CONTRAIL_INTERFACE | grep 52:54:00:12:02 | sed 's/.*52:54:00:12:02:\(..\).*/\1/')
          hostname compute-$NUMBER
          ip a add 192.168.2.$NUMBER dev $CONTRAIL_INTERFACE
          ip l set $CONTRAIL_INTERFACE up
          ip r add 192.168.2.0/24 dev $CONTRAIL_INTERFACE

          IP=$(ip a show $CONTRAIL_INTERFACE | grep "inet "| sed 's|.*inet \(.*\)/.* scope.*|\1|')
          cp ${configFiles.contrail.vrouterAgent} ${contrailVrouterAgentFilepath}
          cat >>${contrailVrouterAgentFilepath} <<EOF
          [VIRTUAL-HOST-INTERFACE]
          name = vhost0
          ip = $IP/24
          gateway = 192.168.2.255
          physical_interface = $CONTRAIL_INTERFACE
          EOF
        '';
      };
    };
  };

  startVm = pkgs.writeShellScriptBin "startVm" ''
    if [ "$COMPUTE_NUMBER" == "" ]; then
      echo "Environment varible COMPUTE_NUMBER must be set! Exiting."
      exit 1
    fi

    if [ "$START_VDE_SWITCH" == 1 ]; then
      echo "Starting VDE switch..."
      ${pkgs.vde2}/bin/vde_switch -d -s /tmp/vde/switch/
    fi

    # We have to wait for all of these ports since QEMU fails to
    # forward to a port which is not listening.
    echo "Start waiting for ports..."
    for i in control:5269 collector:8086 api:8082 discovery:5998; do
      echo Start waiting for $i...
      ${waitFor}/bin/wait-for $i -t 300
    done

    export QEMU_NET_OPTS=hostfwd=udp::51234-:51234,hostfwd=tcp::22-:22,hostfwd=tcp::8085-:8085,guestfwd=tcp:10.0.2.200:5998-tcp:discovery:5998,guestfwd=tcp:10.0.2.200:8082-tcp:api:8082,guestfwd=tcp:10.0.2.200:5269-tcp:control:5269
    export QEMU_OPTS="-net nic,vlan=2,macaddr=52:54:00:12:2:$COMPUTE_NUMBER,model=virtio -net vde,vlan=2,sock=/tmp/vde/switch"
    ${computeNode}/bin/nixos-run-vms
  '';

  computeNode = (makeTest { name = "compute-node"; machine = config; testScript = ""; }).driver;

in 
  # TODO: This image is quiet big. There are some dependencies that should
  # be removed.
  # docker run --device /dev/kvm -d --network dockercompose_cloudwatt -p 2122:22 --name compute1 --volume /tmp/vde/:/tmp/vde vrouter:latest
  pkgs.dockerTools.buildImage {
    name = "vrouter";
    config = { Cmd = [ "${startVm}/bin/startVm" ]; };
  }

