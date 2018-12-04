{ config, pkgs, lib, ... }:

with builtins;
with lib;

let

  cfg = config.contrail.k8s;

  defaultProvision = {
    namespace = "contrail_api_cli.provision";
    defaults = {};
    provision = {
      encaps = {
        modes = [ "MPLSoGRE" "MPLSoUDP" "VXLAN" ];
      };
      bgp-router = [
        {
          router-ip = "10.44.44.50";
          router-name = "control-1";
          router-address-families = [
            "route-target"
            "inet-vpn"
          ];
        }
      ];
    };
  };

in {

  options.contrail.k8s = {

    enable = mkOption {
      type = types.bool;
      default = false;
    };

    provision = mkOption {
      type = types.attrs;
      default = {};
    };

  };

  imports = [
    ./infra_k8s.nix
    ./keystone_k8s.nix
    ./rabbitmq_k8s.nix
    ./zookeeper_k8s.nix
  ];

  config = mkIf cfg.enable {

    infra.k8s = {
      enable = true;
      seedDockerImages = with pkgs.dockerImages; [
        contrailDiscovery
        contrailApiServer
        contrailSchemaTransformer
        contrailSvcMonitor
        contrailAnalytics
        contrailControl
      ];
      vaultPolicies = {
        opencontrail = {
          "secret/opencontrail" = {
            policy = "read";
          };
        };
      };
      vaultData = {
        "secret/opencontrail" = {
          queue_password = "development";
          ifmap_password = "development";
          service_password = "development";
        };
      };
      consulData = {
        "config/opencontrail/data" = {
          log_level = "SYS_INFO";
        };
      };
    };

    rabbitmq.k8s = {
      enable = true;
      vhosts = [ "opencontrail" ];
    };

    keystone.k8s = {
      enable = true;
      projects = {
        service = {
          users = {
            opencontrail = {
              password = "development";
              roles = [ "admin" ];
            };
          };
        };
      };
    };

    zookeeper.k8s = {
      enable = true;
      aliases = [ "opencontrail-config-zookeeper" ];
    };

    environment.etc = {
      "contrail/provision.json".text = toJSON (recursiveUpdate defaultProvision cfg.provision);
      "kubernetes/contrail".source = pkgs.k8sDeployments.contrail.test;
    };

    environment.systemPackages = with pkgs; [
      contrailApiCliWithExtra
    ];

    environment.variables = {
      CONTRAIL_API_HOST = "opencontrail-api.service";
    };

    systemd.services.contrail = {
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = true;
      wantedBy = [ "kubernetes.target" ];
      after = [ "keystone.service" "cassandra.service" "rabbitmq-bootstrap.service" "zookeeper.service" ];
      path = with pkgs; [ kubectl waitFor contrailApiCliWithExtra ];
      environment = {
        CONTRAIL_API_HOST = "opencontrail-api.service";
      };
      script = ''
        kubectl apply -f /etc/kubernetes/contrail/
      '';
      postStart = ''
        wait-for opencontrail-api.service:8082 -t 300 -q
        source /etc/openstack/admin.openrc
        contrail-api-cli provision -f /etc/contrail/provision.json
      '';
    };

  };

}
