{ config, pkgs, lib, ... }:

with builtins;
with lib;

let

  cfg = config.neutron.k8s;

  neutronService = pkgs.lib.mkJSONService {
    application = "neutron";
    service = "api";
  };

  neutronDeployment = pkgs.lib.mkJSONDeployment {
    application = "neutron";
    vaultPolicy = "neutron,nova";
    service = "api";
    port = 9696;
    containers = [ {
      image = with pkgs.dockerImages; "${neutron.imageName}:${pkgs.lib.imageHash neutron}";
      livenessProbe = pkgs.lib.mkHTTPGetProbe "/" 1988 10 30 15;
      readinessProbe = pkgs.lib.mkHTTPGetProbe "/ready" 1988 10 30 15;
      lifecycle = { preStop = { exec = { command = ["/usr/sbin/stop-container"]; };};};
    } ];
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
          "admin_url" = "http://neutron-api.service:9696";
          "internal_url" = "http://neutron-api.service:9696";
          "public_url" = "http://neutron-api.service:9696";
        };
      };
    };

    environment.etc = {
      "kubernetes/neutron/api.deployment.json".text = neutronDeployment;
      "kubernetes/neutron/api.service.json".text = neutronService;
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
