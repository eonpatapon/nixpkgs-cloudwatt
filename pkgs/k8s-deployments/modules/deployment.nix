{ config, lib, k8s, ... }:

with builtins;
with lib;
with k8s;

{

  kubernetes.moduleDefinitions.cwDeployment.module = { name, module, config, ... }: let

    deploymentName = "${config.application}-${config.service}";
    serviceName = "${deploymentName}-pods";

  in {

    options = {

      application = mkOption {
        description = "Name of the application";
        type = types.str;
      };

      service = mkOption {
        description = "Name of the service";
        type = types.str;
      };

      replicas = mkOption {
        description = "Number of replicas";
        type = types.int;
        default = 1;
      };

      image = mkOption {
        description = "Container image to use";
        type = types.str;
      };

      port = mkOption {
        description = "Service port";
        type = types.int;
      };

      vaultPolicy = mkOption {
        description = "Vault policy";
        type = types.str;
        default = "";
      };

      livenessProbe = mkOption {
        type = types.attrs;
        default = {};
      };

      readinessProbe = mkOption {
        type = types.attrs;
        default = {};
      };

      resources = mkOption {
        type = types.attrsOf (types.attrsOf types.str);
        default = {};
      };

    };

    config = mkMerge [
      {
        kubernetes.resources.deployments.${deploymentName} = {
          metadata.name = deploymentName;
          metadata.labels = with config; { inherit application service; };
          spec = {
            replicas = config.replicas;
            selector.matchLabels = with config; { inherit application service; };
            template = {
              metadata.labels = with config; { inherit application service; };
              spec = {
                dnsPolicy = "Default";
                securityContext.fsGroup = 65534;
                terminationGracePeriodSeconds = 1200;
                containers.${deploymentName} = mkMerge [
                  {
                    image = config.image;
                    ports = [
                      { containerPort = config.port; }
                    ];
                    volumeMounts = [
                      { name = "config"; mountPath = "/run/consul-template-wrapper"; }
                    ] ++ optional (config.vaultPolicy != "") {
                      name = "vault-token"; mountPath = "/run/vault-token";
                    };
                    env = [
                      {
                        name = "openstack_region";
                        valueFrom = {
                          configMapKeyRef = {
                            name = "openstack";
                            key = "region";
                          };
                        };
                      }
                      { name = "application"; value = config.application; }
                      { name = "service"; value = config.service; }
                    ];
                  }
                  (mkIf (config.livenessProbe != {}) {
                    livenessProbe = config.livenessProbe;
                  })
                  (mkIf (config.readinessProbe != {}) {
                    readinessProbe = config.readinessProbe;
                  })
                  (mkIf (config.resources != {}) {
                    resources = config.resources;
                  })
                ];
                volumes = [
                  { name = "config"; emptyDir = {}; }
                ] ++ optional (config.vaultPolicy != "") {
                  name = "vault-token";
                  flexVolume = {
                    driver = "cloudwatt/vaulttmpfs";
                    options = {
                      "vault/policies" = config.vaultPolicy;
                    };
                  };
                };
              };
            };
          };
        };

        kubernetes.resources.services."${serviceName}" = {
          metadata = { name = "${serviceName}"; };
          spec = {
            clusterIP = "None";
            ports = [
              { port = config.port; }
            ];
            selector = with config; { inherit application service; };
          };
        };
      }

    ];

  };


}
