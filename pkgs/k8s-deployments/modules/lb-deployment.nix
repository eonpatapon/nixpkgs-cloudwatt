{ config, lib, k8s, pkgs, ... }:

with builtins;
with lib;
with k8s;
with pkgs.dockerImages;

let

  modules = config.kubernetes.modules;

in {

  kubernetes.moduleDefinitions.cwLbDeployment.module = { name, module, config, ... }: let

    appDeploymentName = "${config.application}-${config.service}";
    appServiceName = "${appDeploymentName}-pods";
    appModule = findFirst (m: m.module == "cwDeployment" && m.configuration.application == config.application && m.configuration.service == config.service) null (attrValues modules);
    appPort =
      if appModule == null then
        abort "Can't find module for ${appDeploymentName}"
      else if appModule.configuration.port == 1 then
        abort "No port configured for ${appDeploymentName}"
      else
        appModule.configuration.port;
    lbDeploymentName = "${appDeploymentName}-lb";
    lbServiceName = "${appDeploymentName}-lb";

  in {

    options = {

      application = mkOption {
        description = "Application to load balance";
        type = types.str;
      };

      service = mkOption {
        description = "Service to load balance";
      };

      replicas = mkOption {
        description = "Number of LB replicas";
        type = types.int;
        default = 2;
      };

      image = mkOption {
        description = "LB container image to use";
        type = types.str;
        default = "r.cwpriv.net/kubernetes/haproxy:1.7.9-f3231262b123a213";
      };

    };

    config = mkMerge [
      {
        kubernetes.resources.deployments."${lbDeploymentName}" = {
          metadata.name = "${lbDeploymentName}";
          spec = {
            replicas = 2;
            selector.matchLabels = with config; { inherit application; service = "${service}-lb"; };
            template = {
              metadata = {
                annotations = {
                  "prometheus.io/scrape" = "true";
                  "prometheus.io/port" = "9382";
                };
                labels = with config; {
                  inherit application;
                  service = "${service}-lb";
                };
              };
              spec = {
                dnsPolicy = "Default";
                containers."${lbDeploymentName}" = {
                  image = "r.cwpriv.net/kubernetes/haproxy:1.7.9-f3231262b123a213";
                  env = {
                    application.value = config.application;
                    service.value = "${config.service}-lb";
                    BACKEND_CHECK_INTER.value = "30s";
                    BACKEND_SERVICE.value = appServiceName;
                    CORS_HEADERS.value = "1";
                    FRONTEND_SERVICE.value = "${config.service}-lb";
                    FRONTEND_PORT.value = "${toString appPort}";
                  };
                  ports = [ { containerPort = appPort; } ];
                  lifecycle.preStop.exec.command = ["/usr/sbin/stop-container"];
                  livenessProbe.httpGet = {
                    path = "/";
                    port = appPort;
                    httpHeaders = [ { name = "X-Cloudwatt-Healthcheck"; value = "1"; } ];
                  };
                  livenessProbe.initialDelaySeconds = 10;
                  livenessProbe.periodSeconds = 5;
                  livenessProbe.timeoutSeconds = 5;
                  readinessProbe.httpGet = {
                    path = "/";
                    port = appPort;
                    httpHeaders = [ { name = "X-Cloudwatt-Healthcheck"; value = "1"; } ];
                  };
                  readinessProbe.initialDelaySeconds = 10;
                  readinessProbe.periodSeconds = 5;
                  readinessProbe.timeoutSeconds = 5;
                  resources.limits.memory = "512Mi";
                };
                terminationGracePeriodSeconds = 1200;
              };
            };

          };
        };
        kubernetes.resources.services.${lbServiceName} = {
          metadata = { name = lbServiceName; };
          spec = {
            clusterIP = null;
            ports = [
              { port = appPort; }
            ];
            selector = with config; { inherit application; service = "${service}-lb"; };
          };
        };
      }
    ];

  };


}
