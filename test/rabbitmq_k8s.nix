{ pkgs
, lib
, stdenv
}:

with import (pkgs.path + /nixos/lib/testing.nix) { system = builtins.currentSystem; };

let

  master = { config, ... }: {

    imports = [
      ../modules/rabbitmq_k8s.nix
    ];

    config = {
      _module.args = { inherit pkgs lib; };

      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";
      services.openssh.extraConfig = "PermitEmptyPasswords yes";
      users.extraUsers.root.password = "";

      rabbitmq.k8s = {
        enable = true;
        vhosts = [ "foo" ];
      };

      virtualisation = {
        diskSize = 10000;
        memorySize = 2048;
      };

      # # forward some ports on the host for debugging
      # virtualisation.qemu.networkingOptions = [
      #   "-net nic,netdev=user.0,model=virtio"
      #   "-netdev user,id=user.0,hostfwd=tcp::2222-:22"
      # ];

    };

  };

  testScript = ''
    $master->waitForUnit("consul.service");
    $master->waitForUnit("rabbitmq-bootstrap.service");
    # check rabbitmq provisionning
    $master->succeed("su -s ${stdenv.shell} rabbitmq -c 'rabbitmqctl list_users' | grep -q foo");
    $master->succeed("curl -s consul:8500/v1/catalog/services | grep -q foo-queue");
  '';

in
  makeTest {
    name = "rabbitmq";
    nodes = {
      inherit master;
    };
    testScript = testScript;
  }
