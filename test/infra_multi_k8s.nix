{ pkgs, lib }:

with import (pkgs.path + /nixos/lib/testing.nix) { system = builtins.currentSystem; };

let

  k8sDeployments = { ... }: {

    require = [ ../pkgs/k8s-deployments/modules/deployment.nix ];

    kubernetes.modules.service1 = {
      module = "cwDeployment";
      configuration = {
        replicas = 2;
        application = "test";
        service = "service1";
        image = "${service1Image.imageName}:${lib.imageHash service1Image}";
        port = 1;
      };
    };

    kubernetes.modules.service2 = {
      module = "cwDeployment";
      configuration = {
        replicas = 2;
        application = "test";
        service = "service2";
        image = "${service2Image.imageName}:${lib.imageHash service2Image}";
        vaultPolicy = "service2";
        port = 1;
      };
    };

  };

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

  certs = import (pkgs.path + /nixos/tests/kubernetes/certs.nix) {
    inherit pkgs;
    externalDomain = "dev0.loc.cloudwatt.net";
    kubelets = [ "master" "node1" "node2" ];
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
        roles = [ "master" ];
        certificates = certs;
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
        diskSize = 4000;
        memorySize = 2048;
      };

      # # forward some ports on the host for debugging
      # virtualisation.qemu.networkingOptions = [
      #   "-net nic,netdev=user.0,model=virtio"
      #   "-netdev user,id=user.0,hostfwd=tcp::2222-:22"
      # ];

      environment.systemPackages = with pkgs; [ jq kubectl docker vault dnsutils ];

      environment.etc = {
        "kubernetes/test/resources.json".source = lib.buildK8SResources k8sDeployments;
      };

    };

  };

  node = { config, ... }: {

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
        roles = [ "node" ];
        certificates = certs;
        seedDockerImages = [
          service1Image
          service2Image
        ];
      };

      virtualisation = {
        diskSize = 4000;
        memorySize = 1024;
      };

      environment.systemPackages = with pkgs; [ jq docker dnsutils ];

    };

  };

  testScript = ''
    startAll();
    $master->waitForUnit("docker.service");
    $master->waitForUnit("vault.service");
    $master->waitForUnit("consul.service");
    $master->waitForUnit("kube-bootstrap.service");
    $node1->waitForUnit("kubelet.service");
    $node2->waitForUnit("kubelet.service");
    $master->waitUntilSucceeds("kubectl get nodes | tail -n +2 | grep Ready | wc -l | grep -q 3");
    # check k8s deployment
    $master->succeed("kubectl apply -f /etc/kubernetes/test");
    $master->waitUntilSucceeds("kubectl get pods -l application=test | wc -l | grep -q 5");
    $master->waitUntilSucceeds("kubectl get services | grep -q test-service1-pods");
    $master->waitUntilSucceeds("kubectl get services | grep -q test-service2-pods");
    # check kube2consul
    $master->waitUntilSucceeds("curl -s consul:8500/v1/catalog/services | grep -q test-service1-pods");
    $master->waitUntilSucceeds("curl -s consul:8500/v1/catalog/services | grep -q test-service2-pods");
    # check networking between nodes
    $master->succeed("kubectl exec \$(kubectl get pod -l service=service1 -o jsonpath='{.items[0].metadata.name}') -- ping -c1 \$(kubectl get pod -l service=service1 -o jsonpath='{.items[1].status.podIP}')");
    # check consul-template with vault secrets on both nodes
    $master->waitUntilSucceeds("kubectl exec \$(kubectl get pod -l service=service2 -o jsonpath='{.items[0].metadata.name}') -- cat /run/consul-template-wrapper/result | grep -q foo");
    $master->waitUntilSucceeds("kubectl exec \$(kubectl get pod -l service=service2 -o jsonpath='{.items[1].metadata.name}') -- cat /run/consul-template-wrapper/result | grep -q foo");
    $master->waitUntilSucceeds("kubectl exec \$(kubectl get pod -l service=service2 -o jsonpath='{.items[0].metadata.name}') -- cat /run/consul-template-wrapper/result | grep -q plop");
    $master->waitUntilSucceeds("kubectl exec \$(kubectl get pod -l service=service2 -o jsonpath='{.items[1].metadata.name}') -- cat /run/consul-template-wrapper/result | grep -q plop");
    # check fluentd forwarding
    $node1->waitUntilSucceeds("journalctl --unit fluentd --no-pager --grep service1");
    $node2->waitUntilSucceeds("journalctl --unit fluentd --no-pager --grep service1");
  '';

in
  makeTest {
    name = "infra-multi-k8s";
    nodes = {
      inherit master;
      node1 = node;
      node2 = node;
    };
    testScript = testScript;
  }
