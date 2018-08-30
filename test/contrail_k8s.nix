{ pkgs
, cwPkgs
, contrailPkgs
, contrailPath
, lib
, stdenv
}:

with import (pkgs.path + /nixos/lib/testing.nix) { system = builtins.currentSystem; };

let

  publicNetName = "public";
  publicNetPrefix = "10.0.0.0";
  publicNetPrefixLen = 24;

  # we don't care about setting a correct tenant_id or user_id
  # because is_admin is set to true
  vncOpenstackRequest = pkgs.writeTextFile {
    name = "request.json";
    text = builtins.toJSON {
      context = {
        type = "network";
        operation = "READALL";
        tenant_id = "6d5e09f8e1194f928afece567b6e56f5";
        user_id = "6d5e09f8e1194f928afece567b6e56f5";
        request_id = "req-f79fa546-ec4c-4bcc-9f4d-b535974312b8";
        is_admin = true;
      };
      data = {
        fields = [];
        filters = {};
      };
    };
  };

  checkVncOpenstack = pkgs.writeShellScriptBin "check-vnc_openstack" ''
    source /etc/openstack/admin.openrc
    export TOKEN=$(openstack token issue -f value -c id)
    curl -i -X POST -H "X-Auth-Token: $TOKEN" -H "Content-type: application/json" \
      --data @${vncOpenstackRequest} http://opencontrail-api.service:8082/neutron/network | grep -q '200 OK'
  '';

  controller = { config, ... }: {

    imports = [
      ../modules/infra_k8s.nix
      (contrailPath + /modules/cassandra.nix)
      ../modules/contrail_k8s.nix
    ];

    config = {
      _module.args = { inherit cwPkgs; cwLibs = lib; };

      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";
      services.openssh.extraConfig = "PermitEmptyPasswords yes";
      users.extraUsers.root.password = "";

      # we ping the controller from contrail with an IP from the public network
      # so the controller needs to know how to send back packets. Destination can
      # be either vrouter.
      networking.interfaces.eth1.ipv4.routes = [
        { address = publicNetPrefix; prefixLength = publicNetPrefixLen; via = "192.168.1.2"; }
      ];

      infra.k8s = {
        enable = true;
        externalServices = {
          opencontrail-config-cassandra = {
            address = "169.254.1.52";
            port = 9160;
          };
          opencontrail-analytics-cassandra = {
            address = "169.254.1.52";
            port = 9042;
          };
        };
      };

      services.cassandra = {
        enable = true;
        rpcAddress = "169.254.1.52";
      };

      contrail.k8s = {
        enable = true;
        provision = {
          defaults = {
            vn = { project-fqname = "default-domain:service"; };
            lr = { project-fqname = "default-domain:service"; };
          };
          provision = {
            vrouter = [
              {
                vrouter-ip = "192.168.2.2";
                vrouter-name = "vrouter1";
              }
              {
                vrouter-ip = "192.168.2.3";
                vrouter-name = "vrouter2";
              }
            ];
            vn = [
              {
                virtual-network-name = publicNetName;
                subnets = [ "${publicNetPrefix}/${toString publicNetPrefixLen}" ];
                external = true;
              }
              {
                virtual-network-name = "vn1";
                subnets = [ "20.1.1.0/24" ];
              }
              {
                virtual-network-name = "vn2";
                subnets = [ "20.2.2.0/24" ];
              }
            ];
            lr = {
              logical-router-name = "router";
              vn-fqnames = [ "default-domain:service:vn1" "default-domain:service:vn2" ];
              external-vn-fqname = "default-domain:service:${publicNetName}";
            };
          };
        };
      };

      virtualisation = {
        diskSize = 10000;
        memorySize = 8192;
        cores = 2;
      };

      # # forward some ports on the host for debugging
      # virtualisation.qemu.networkingOptions = [
      #   "-net nic,netdev=user.0,model=virtio"
      #   "-netdev user,id=user.0,hostfwd=tcp::2221-:22"
      # ];

    };

  };

  vrouterConfig = ip: pkgs.writeTextFile {
    name = "contrail-vrouter-agent.conf";
    text = ''
      [DEFAULT]
      disable_flow_collection = 1
      log_level = SYS_DEBUG

      [DISCOVERY]
      server = opencontrail-discovery.service
      port = 5998

      [VIRTUAL-HOST-INTERFACE]
      name = vhost0
      ip = 192.168.2.${ip}/24
      gateway = 192.168.2.1
      physical_interface = eth2

      [FLOWS]
      max_vm_flows = 20

      [METADATA]
      metadata_proxy_secret = t96a4skwwl63ddk6

      [TASK]
      tbb_keepawake_timeout = 25

      [SERVICE-INSTANCE]
      netns_command = ${contrailPkgs.vrouterNetns}/bin/opencontrail-vrouter-netns
    '';
  };

  vncApiLib = pkgs.writeTextFile {
    name = "vnc_api_lib.ini";
    text = ''
      [auth]
      AUTHN_TYPE = keystone
      AUTHN_PROTOCOL = http
      AUTHN_SERVER = keystone-api.service
      AUTHN_PORT = 5000
      AUTHN_URL = /v2.0/tokens
      AUTHN_TOKEN_URL = http://keystone-api.service:5000/v2.0/tokens
    '';
  };

  vrouter = ip: { config, ... }: {
    imports = [ (contrailPath + "/modules/compute-node.nix") ];

    config = {
      _module.args = { inherit contrailPkgs; isContrailMaster=false; isContrail32=true; };

      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";
      services.openssh.extraConfig = "PermitEmptyPasswords yes";
      users.extraUsers.root.password = "";

      networking.firewall.enable = false;
      networking.nameservers = [ "192.168.1.1" ];
      networking.domain = "dev0.loc.cloudwatt.net";
      networking.interfaces.eth1.ipv4.routes = [
        { address = "10.44.44.0"; prefixLength = 24; via = "192.168.1.1"; }
        { address = "169.254.1.0"; prefixLength = 24; via = "192.168.1.1"; }
      ];

      environment.etc = {
        "contrail/vnc_api_lib.ini".source = vncApiLib;
      };

      virtualisation.memorySize = 1024;
      virtualisation.vlans = [ 1 2 ];

      # # forward some ports on the host for debugging
      # virtualisation.qemu.networkingOptions = [
      #   "-net nic,netdev=user.0,model=virtio"
      #   "-netdev user,id=user.0,hostfwd=tcp::222${ip}-:22"
      # ];

      contrail.vrouterAgent = {
        enable = true;
        provisionning = false;
        configurationFilepath = "${vrouterConfig ip}";
        contrailInterfaceName = "eth2";
      };

      # TODO: add in compute module
      systemd.services.addVGW = {
        serviceConfig.Type = "oneshot";
        serviceConfig.RemainAfterExit = true;
        wantedBy = [ "multi-user.target" ];
        after = [ "contrailVrouterAgent.service" ];
        script = ''
          ${cwPkgs.waitFor}/bin/wait-for localhost:9091 -t 300
          ${contrailPkgs.configUtils}/bin/provision_vgw_interface.py --oper create \
              --interface vgw --subnets ${publicNetPrefix}/${toString publicNetPrefixLen} --routes 0.0.0.0/0 \
              --vrf "default-domain:service:${publicNetName}:${publicNetName}"
        '';
      };

    };

  };

  testScript = ''
    $controller->start();
    $controller->sleep(300);
    $controller->waitForUnit("contrail.service");

    # check services state
    my @services = qw(ApiServer IfmapServer Collector OpServer xmpp-server);
    foreach my $service (@services)
    {
      $controller->waitUntilSucceeds(sprintf("curl -s opencontrail-discovery.service:5998/services.json | jq -e '.services[] | select(.service_type == \"%s\" and .oper_state == \"up\")'", $service));
    }

    # check vnc_openstack
    $controller->succeed("${checkVncOpenstack}/bin/check-vnc_openstack");

    # we start vrouters when disco and control are ready
    $vrouter1->start();
    $vrouter2->start();

    # check all vrouters are present and functionnal
    $controller->waitUntilSucceeds("curl -s opencontrail-analytics.service:8081/analytics/uves/vrouter/*?cfilt=NodeStatus:process_status | jq -e '.[][].value.NodeStatus.process_status[] | select(.state == \"Functional\")' | jq -s '. | length' | grep -q 2");

    # force svc restart to schedule the SI on vrouters
    $controller->sleep(10);
    $controller->succeed("kubectl delete pod \$(kubectl get pod -l service=svc-monitor -o jsonpath='{.items[0].metadata.name}')");

    $vrouter1->succeed("netns-daemon-start -U opencontrail -P development -s opencontrail-api.service -n default-domain:service:vn1 vm1");
    $vrouter2->succeed("netns-daemon-start -U opencontrail -P development -s opencontrail-api.service -n default-domain:service:vn1 vm2");
    $vrouter2->succeed("netns-daemon-start -U opencontrail -P development -s opencontrail-api.service -n default-domain:service:vn2 vm3");

    $vrouter1->succeed("ip netns exec ns-vm1 ip a | grep -q 20.1.1.252");
    # ping in same network
    $vrouter1->succeed("ip netns exec ns-vm1 ping -c1 20.1.1.251");
    # ping through router
    $vrouter1->succeed("ip netns exec ns-vm1 ping -c1 20.2.2.252");
    # check snat is properly scheduled on each vrouter
    $vrouter1->waitUntilSucceeds("ip netns | grep -q vrouter");
    $vrouter2->waitUntilSucceeds("ip netns | grep -q vrouter");
    # ping controller via SNAT
    # first ping may fails, but next one should succeed
    $vrouter1->waitUntilSucceeds("ip netns exec ns-vm1 ping -c1 192.168.1.1");
  '';

in
  makeTest {
    name = "contrail";
    nodes = {
      inherit controller;
      # IPs for vrouters will be 192.168.1.{2,3}
      vrouter1 = vrouter "2";
      vrouter2 = vrouter "3";
    };
    testScript = testScript;
  }
