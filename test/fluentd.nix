{ pkgs
, fluentdCw
, lib
}:

with import (pkgs.path + /nixos/lib/testing.nix) { system = builtins.currentSystem; };

let

  fluentdConf = pkgs.writeTextFile {
    name = "fluentd.conf";
    text = ''
      <source>
        @type forward
        port 24224
      </source>
      <match **>
        @type stdout
      </match>
    '';
  };

  stdoutSvc = pkgs.writeShellScriptBin "stdout-svc" ''
    while true
    do
      echo "stdout-svc"
      sleep 1
    done
  '';

  stderrSvc = pkgs.writeShellScriptBin "stderr-svc" ''
    while true
    do
      >&2 echo "stderr-svc"
      sleep 1
    done
  '';

  syslogSvc = pkgs.writeShellScriptBin "syslog-svc" ''
    while true
    do
      echo "<133>$0[$$]: syslog-svc" | nc -w1 -u localhost 1234
      sleep 1
    done
  '';

  testImage = lib.buildImageWithPerps {
    name = "test-image";
    services = [
      {
        name = "stdout-svc";
        command = "${stdoutSvc}/bin/stdout-svc";
        fluentd = {
          source = {
            type = "stdout";
          };
        };
      }
      {
        name = "stderr-svc";
        command = "${stderrSvc}/bin/stderr-svc";
        fluentd = {
          source = {
            type = "stdout";
          };
        };
      }
      {
        name = "syslog-svc";
        command = "${syslogSvc}/bin/syslog-svc";
        fluentd = {
          source = {
            type = "syslog";
            port = 1234;
            format = "none";
          };
        };
      }
    ];
  };

  machine = { config, ... }: {
    config = rec {
      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";
      services.openssh.extraConfig = "PermitEmptyPasswords yes";
      users.extraUsers.root.password = "";

      virtualisation = { diskSize = 4960; memorySize = 1024; };
      virtualisation.docker.enable = true;
      virtualisation.dockerPreloader.images = [ testImage ];

      networking.hosts = {
        "127.0.0.1" = [ "fluentd.localdomain" ];
      };

      systemd.services.fluentd = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        script = "${fluentdCw}/bin/fluentd --no-supervisor -c ${fluentdConf}";
      };

    };
  };

  testScript = with lib; ''
    $machine->waitForUnit("docker.service");
    $machine->waitForUnit("fluentd.service");
    $machine->succeed("docker run -d --net host ${testImage.imageName}:${imageHash testImage}");
    # fluentd has flush_interval set to 10s
    $machine->sleep(10);
    $machine->waitUntilSucceeds("journalctl --unit fluentd --no-pager --grep stdout-svc");
    $machine->waitUntilSucceeds("journalctl --unit fluentd --no-pager --grep stderr-svc");
    $machine->waitUntilSucceeds("journalctl --unit fluentd --no-pager --grep syslog-svc");
  '';
in
  makeTest { name = "fluentd"; nodes = { inherit machine; }; testScript = testScript; }
