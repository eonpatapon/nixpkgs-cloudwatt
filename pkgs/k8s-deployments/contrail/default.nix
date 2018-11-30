{ lib, dockerImages }:

with lib;
with dockerImages;

let

  noLb = _: _: resource: ! (hasSuffix "-lb" resource.metadata.name);

  defaultDeployments = {
    apiServer.deployment = ./api-server.nix;
    discovery.deployment = ./discovery.nix;
    schemaTransformer.deployment = ./schema-transformer.nix;
    svcMonitor.deployment = ./svc-monitor.nix;
    analytics.deployment = ./analytics.nix;
    control1 = {
      deployment = ./control.nix;
      overrides = {
        kubernetes.modules.control.configuration = {
          number = 1;
        };
      };
    };
    control2 = {
      deployment = ./control.nix;
      overrides = {
        kubernetes.modules.control.configuration = {
          number = 2;
        };
      };
    };
  };

  lab2Deployments = recursiveUpdate defaultDeployments {
    control1.overrides = {
      kubernetes.modules.control.configuration.ipAddress = "10.35.6.10";
    };
    control2.overrides = {
      kubernetes.modules.control.configuration.ipAddress = "10.35.6.11";
    };
  };

  testDeployments = removeAttrs (recursiveUpdate defaultDeployments {
    apiServer = {
      filter = noLb;
      overrides = {
        kubernetes.modules.api.configuration = {
          replicas = mkForce 1;
          resources.requests.memory = mkForce "5Mi";
          kubernetes.resources.services.opencontrail-api-pods = {
            metadata.name = mkForce "opencontrail-api";
          };
        };
      };
    };
    discovery = {
      filter = noLb;
      overrides = {
        kubernetes.modules.discovery.configuration = {
          replicas = mkForce 1;
          resources.requests.memory = mkForce "5Mi";
          kubernetes.resources.services.opencontrail-discovery-pods = {
            metadata.name = mkForce "opencontrail-discovery";
          };
        };
      };
    };
    schemaTransformer = {
      overrides = {
        kubernetes.modules.schema-transformer.configuration = {
          resources.requests.memory = mkForce "5Mi";
          replicas = mkForce 1;
        };
      };
    };
    svcMonitor = {
      overrides = {
        kubernetes.modules.svc-monitor.configuration = {
          resources.requests.memory = mkForce "5Mi";
          replicas = mkForce 1;
        };
      };
    };
    analytics = {
      overrides = {
        kubernetes.modules.analytics.configuration = {
          resources.requests.memory = mkForce "5Mi";
          replicas = mkForce 1;
        };
      };
    };
    control1 = {
      overrides = {
        kubernetes.modules.control.configuration = {
          ipAddress = "10.44.43.50";
          kubernetes.modules.control-1.configuration = {
            resources.requests.memory = mkForce "5Mi";
          };
        };
      };
    };
  }) [ "control2" ];

in {

  lab2 = buildK8SDeployments lab2Deployments;

  test = buildK8SDeployments testDeployments;

}
