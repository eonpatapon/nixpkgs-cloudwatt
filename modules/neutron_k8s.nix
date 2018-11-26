{ config, pkgs, lib, ... }:

with builtins;
with lib;

let

  cfg = config.neutron.k8s;

  k8sResources = { ... }: with pkgs.dockerImages; with pkgs.platforms; {
    kubernetes.resources = {
      deployments.neutron-api = mkMerge [
        (pkgs.lib.kubenix.loadYAML (lab2 + /kubernetes/neutron/api.deployment.yml))
        {
          spec.replicas = 1;
          spec.selector.matchLabels.application = "neutron";
          spec.template.spec.containers.neutron-api = {
            resources.requests.memory = "5Mi";
            image = "${neutron.imageName}:${pkgs.lib.imageHash neutron}";
          };
        }
      ];
      services.neutron-api =
        pkgs.lib.kubenix.loadYAML (lab2 + /kubernetes/neutron/api-pods.service.yml);
    };
  };

in {
  options.neutron.k8s = {

    enable = mkOption {
      type = types.bool;
      default = false;
    };

  };

  imports = [
    ./infra_k8s.nix
    ./keystone_k8s.nix
  ];

  config = mkIf cfg.enable {

    infra.k8s = {
      enable = true;
      seedDockerImages = [ pkgs.dockerImages.neutron ];

      vaultPolicies = {
        neutron = {
          "secret/neutron" = {
            policy = "read";
          };
          "secret/nova" = {
            policy = "read";
          };
        };
      };
      vaultData = {
        "secret/neutron" = {
          service_password = "development";
        };
        "secret/nova" = {
          service_password = "development";
        };
      };
      consulData = {
        "config/neutron/data" = {
          opencontrail = {
            api_url = "opencontrail-api.service";
            analytics_api_url = "opencontrail-analytics-api.service";
          };
        };
      };
    };

    keystone.k8s = {
      enable = true;
      projects = {
        service = {
          users = {
            neutron = {
              password = "development";
              roles = [ "admin" ];
            };
          };
        };
      };
      catalog = {
        "network" = {
          "name" = "neutron";
          "admin_url" = "http://neutron-api-pods.service:9696";
          "internal_url" = "http://neutron-api-pods.service:9696";
          "public_url" = "http://neutron-api-pods.service:9696";
        };
        "load-balancer" = {
          "name" = "neutron";
          "admin_url" = "http://neutron-api-pods.service:9696";
          "internal_url" = "http://neutron-api-pods.service:9696";
          "public_url" = "http://neutron-api-pods.service:9696";
        };
      };
    };

    environment.etc = {
      "kubernetes/neutron/resources.json".source = pkgs.lib.buildK8SResources k8sResources;
    };

    systemd.services.neutron = {
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      wantedBy = [ "kubernetes.target" ];
      after = [ "kube-bootstrap.service" "keystone.service" ];
      path = [ pkgs.kubectl ];
      script = ''
        kubectl apply -f /etc/kubernetes/neutron
      '';
    };

  };
}
