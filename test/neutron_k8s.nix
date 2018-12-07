{ pkgs
, lib
, stdenv
, contrailPkgs
}:

with import (pkgs.path + /nixos/lib/testing.nix) { system = builtins.currentSystem; };

let

  apiConf = pkgs.writeTextFile {
    name = "contrail-api.conf";
    text = ''
      [DEFAULTS]
      log_level = SYS_DEBUG
      log_local = 1
      cassandra_server_list = localhost:9160
      disc_server_ip = localhost
      disc_server_port = 5998

      rabbit_port = 5672
      rabbit_server = localhost
      listen_port = 8082
      listen_ip_addr = 0.0.0.0
      zk_server_port = 2181
      zk_server_ip = localhost

      [IFMAP_SERVER]
      ifmap_listen_ip = 0.0.0.0
      ifmap_listen_port = 8443
      ifmap_credentials = api-server:api-server

      [KEYSTONE]
      admin_password=development
      admin_tenant_name=service
      admin_user=neutron
      auth_host=keystone-admin-api.service.dev0.loc.cloudwatt.net
      auth_port=35357
      auth_protocol=http
      region=dev0
  '';
  };

  certs = import (pkgs.path + /nixos/tests/kubernetes/certs.nix) {
    inherit pkgs;
    externalDomain = "dev0.loc.cloudwatt.net";
    kubelets = [ "machine" ];
  };

  machine = { config, ... }: {
    imports = [
      ../modules/neutron_k8s.nix
      (contrailPkgs.modules + "/contrail-api.nix")
      (contrailPkgs.modules + "/cassandra.nix")
    ];

    config = {
      _module.args = {
        inherit contrailPkgs lib pkgs;
      };

      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";
      services.openssh.extraConfig = "PermitEmptyPasswords yes";
      users.extraUsers.root.password = "";

      virtualisation = {
        diskSize = 10000;
        memorySize = 4096;
        cores = 2;
      };

      neutron.k8s.enable = true;

      infra.k8s = {
        roles = [ "master" "node" ];
        certificates = certs;
        externalServices = {
          opencontrail-api = {
            address = "169.254.1.20";
            port = 0;
          };
        };
      };

      cassandra.enable = true;

      contrail = {
        api = {
          enable = true;
          configFile = apiConf;
          waitFor = false;
        };
      };
    };
  };

  testScript = ''
    $machine->waitForUnit("neutron.service");
    $machine->waitUntilSucceeds("source /etc/openstack/admin.openrc && openstack network list");
    $machine->waitUntilSucceeds("source /etc/openstack/admin.openrc && openstack loadbalancer pool list");
  '';

in
  makeTest {
    name = "neutron";
    nodes = {
      inherit machine;
    };
    testScript = testScript;
  }
