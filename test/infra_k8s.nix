{ pkgs
, lib
, stdenv
}:

with import (pkgs.path + /nixos/lib/testing.nix) { system = builtins.currentSystem; };

let

  service1 = pkgs.writeShellScriptBin "service1" ''
    while true
    do
      echo "service1"
      sleep 1
    done
  '';

  service1Image = lib.buildImageWithPerps {
    name = "test/service1";
    services = [
      {
        name = "service1";
        command = "${service1}/bin/service1";
        fluentd = {
          source = {
            type = "stdout";
          };
        };
      }
    ];
  };

  service1Deployment = lib.mkJSONDeployment {
    application = "test";
    service = "service1";
    containers = [
      { image = "${service1Image.imageName}:${lib.imageHash service1Image}"; }
    ];
  };

  service1Service = lib.mkJSONService {
    application = "test";
    service = "service1";
  };

  service2 = pkgs.writeShellScriptBin "service2" ''
    while true
    do
      sleep 1
    done
  '';

  service2Template = pkgs.writeTextFile {
    name = "template";
    text = ''
      {{ $service2 := key "/service2" | parseJSON -}}
      {{ $service2.data }}
	  {{- with secret "secret/service2" -}}
		{{ .Data.password }}
	  {{- end }}
    '';
  };

  service2Image = lib.buildImageWithPerps {
    name = "test/service2";
    services = [
      {
        name = "service2";
        command = "${service2}/bin/service2";
        preStartScript = ''
          consul-template-wrapper --no-lock -- -once \
            -template "${service2Template}:/run/consul-template-wrapper/result"
        '';
      }
    ];
  };

  service2Deployment = lib.mkJSONDeployment' {
    application = "test";
    service = "service2";
    vaultPolicy = "service2";
    containers = [
      {
        image = "${service2Image.imageName}:${lib.imageHash service2Image}";
        env = [
          { name = "test"; value = "test"; }
        ];
      }
    ];
  } {
    spec = {
      template = {
        spec = {
          # mode for volumeMounts so that user can access it
          securityContext = { fsGroup = 65534; };
        };
      };
    };
  };

  service2Service = lib.mkJSONService {
    application = "test";
    service = "service2";
  };

  master = { config, ... }: {

    imports = [
      ../modules/infra_k8s.nix
    ];

    config = {
      _module.args = { inherit pkgs lib; };

      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";
      services.openssh.extraConfig = "PermitEmptyPasswords yes";
      users.extraUsers.root.password = "";

      infra.k8s = {
        enable = true;
        externalServices = {
          foo = {
            address = "169.254.1.100";
            port = 2222;
          };
        };
        seedDockerImages = [
          service1Image
          service2Image
        ];
        consulData = {
          service2 = {
            data = "foo";
          };
        };
        vaultData = {
          "secret/service2" = {
            password = "plop";
          };
        };
        vaultPolicies = {
          "service2" = {
            "secret/service2" = {
              policy = "read";
            };
          };
        };
      };

      virtualisation = {
        diskSize = 10000;
        memorySize = 4096;
      };

      # # forward some ports on the host for debugging
      # virtualisation.qemu.networkingOptions = [
      #   "-net nic,netdev=user.0,model=virtio"
      #   "-netdev user,id=user.0,hostfwd=tcp::2222-:22"
      # ];

      environment.systemPackages = with pkgs; [ jq kubectl docker vault dnsutils openstackClient ];

      environment.etc = {
        "kubernetes/test/service1.deployment.json".text = service1Deployment;
        "kubernetes/test/service2.deployment.json".text = service2Deployment;
        "kubernetes/test/service1.service.json".text = service1Service;
        "kubernetes/test/service2.service.json".text = service2Service;
      };

    };

  };

  testScript = ''
    $master->waitForUnit("docker.service");
    $master->waitForUnit("kube-bootstrap.service");
    $master->waitForUnit("vault.service");
    $master->waitForUnit("consul.service");
    # check external service provisionning
    $master->succeed("grep -q foo /etc/hosts");
    # check consul provisionning
    $master->succeed("curl -s http://consul:8500/v1/kv/service2 | jq -r '.[].Value' | base64 -d | jq -e '.data == \"foo\"'");
    # check k8s deployment
    $master->succeed("kubectl apply -f /etc/kubernetes/test/");
    $master->waitUntilSucceeds("kubectl get pods -l application=test | wc -l | grep -q 3");
    $master->waitUntilSucceeds("kubectl get services | grep -q test-service1");
    # check kube2consul
    $master->waitUntilSucceeds("curl -s consul:8500/v1/catalog/services | grep -q test-service1");
    # check networking
    $master->succeed("kubectl exec \$(kubectl get pod -l service=service1 -o jsonpath='{.items[0].metadata.name}') -- ping -c1 test-service2.service");
    # check consul-template with vault secrets
    $master->waitUntilSucceeds("kubectl exec \$(kubectl get pod -l service=service2 -o jsonpath='{.items[0].metadata.name}') -- cat /run/consul-template-wrapper/result | grep -q foo");
    $master->waitUntilSucceeds("kubectl exec \$(kubectl get pod -l service=service2 -o jsonpath='{.items[0].metadata.name}') -- cat /run/consul-template-wrapper/result | grep -q plop");
    # check fluentd forwarding
    $master->waitUntilSucceeds("journalctl --unit fluentd --no-pager --grep service1");
  '';

in
  makeTest {
    name = "infra";
    nodes = {
      inherit master;
    };
    testScript = testScript;
  }
