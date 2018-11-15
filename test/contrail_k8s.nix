{ pkgs, lib, contrailPkgs }:

with import (pkgs.path + /nixos/lib/testing.nix) { system = builtins.currentSystem; };

let

  publicNetName = "public";
  publicNetPrefix = "10.0.0.0";
  publicNetPrefixLen = 24;

  controller = { config, ... }: {

    imports = [
      ../modules/infra_k8s.nix
      (contrailPkgs.modules + /cassandra.nix)
      ../modules/contrail_k8s.nix
      ../modules/neutron_k8s.nix
    ];

    config = {
      _module.args = { inherit pkgs lib; };

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

      neutron.k8s.enable = true;

      virtualisation = {
        diskSize = 10000;
        memorySize = 8192;
        cores = 2;
      };

      # forward some ports on the host for debugging
      virtualisation.qemu.networkingOptions = [
        "-net nic,netdev=user.0,model=virtio"
        "-netdev user,id=user.0,hostfwd=tcp::2221-:22"
      ];

    };

  };

  vncApiLib = pkgs.writeTextFile {
    name = "vnc_api_lib.ini";
    text = ''
      [auth]
      AUTHN_TYPE = keystone
      AUTHN_PROTOCOL = http
      AUTHN_SERVER = keystone-api-pods.service
      AUTHN_PORT = 5000
      AUTHN_URL = /v2.0/tokens
      AUTHN_TOKEN_URL = http://keystone-api-pods.service:5000/v2.0/tokens
    '';
  };

  vrouter = ip: { config, ... }: {
    imports = [ (contrailPkgs.modules + "/compute-node.nix") ];

    config = {
      _module.args = { inherit pkgs contrailPkgs; };

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
        vhostIP = "192.168.2.${ip}";
        vhostGateway = "192.168.2.1";
        vhostInterface = "eth2";
        discoveryHost = "opencontrail-discovery.service";
        virtualGateways = [
          {
            networkName = "public";
            networkCIDR = "${publicNetPrefix}/${toString publicNetPrefixLen}";
            routes = "0.0.0.0/0";
          }
        ];
      };
    };

  };

  testScript = ''
    $controller->start();
    $controller->sleep(200);
    $controller->waitForUnit("contrail.service");

    # check services state
    my @services = qw(ApiServer IfmapServer Collector OpServer xmpp-server);
    foreach my $service (@services)
    {
      $controller->waitUntilSucceeds(sprintf("curl -s opencontrail-discovery.service:5998/services.json | jq -e '.services[] | select(.service_type == \"%s\" and .oper_state == \"up\")'", $service));
    }

    # check neutron container
    $controller->succeed("source /etc/openstack/admin.openrc && openstack network list");

    # we start vrouters when disco and control are ready
    $vrouter1->start();
    $vrouter2->start();

    # check all vrouters are present and functionnal
    $controller->waitUntilSucceeds("curl -s opencontrail-analytics.service:8081/analytics/uves/vrouter/*?cfilt=NodeStatus:process_status | jq '.value | map(select(.value.NodeStatus.process_status[0].state == \"Functional\")) | length' | grep -q 2");
    $controller->waitUntilSucceeds("curl -s opencontrail-analytics.service:8081/analytics/uves/vrouter/*?cfilt=VrouterAgent:mode | jq '.value | length' | grep -q 2");

    # force svc restart to schedule the SI on vrouters
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

    # check that all services logs are captured
    $controller->succeed("journalctl --unit fluentd --no-pager --grep log.opencontrail-api");
    $controller->succeed("journalctl --unit fluentd --no-pager --grep log.opencontrail-discovery");
    $controller->succeed("journalctl --unit fluentd --no-pager --grep log.opencontrail-svc-monitor");
    $controller->succeed("journalctl --unit fluentd --no-pager --grep log.opencontrail-schema-transformer");
    $controller->succeed("journalctl --unit fluentd --no-pager --grep log.opencontrail-analytics-api");
    $controller->succeed("journalctl --unit fluentd --no-pager --grep log.opencontrail-collector");
    $controller->succeed("journalctl --unit fluentd --no-pager --grep log.opencontrail-query-engine");
    $controller->succeed("journalctl --unit fluentd --no-pager --grep log.opencontrail-control");
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
