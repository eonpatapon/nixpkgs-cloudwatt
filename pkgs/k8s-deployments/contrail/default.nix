{ lib, dockerImages, buildAppDeployment }:

with lib;
with dockerImages;

let

  noLb = _: _: resource: ! (hasSuffix "-lb" resource.metadata.name);

  buildDeployments =
    mapAttrs (_: { deployment, config ? {} }: buildAppDeployment deployment config);

  defaultDeployments = {
    apiServer.deployment = ./api-server.nix;
    discovery.deployment = ./discovery.nix;
    schemaTransformer.deployment = ./schema-transformer.nix;
    svcMonitor.deployment = ./svc-monitor.nix;
    analytics.deployment = ./analytics.nix;
    control1 = {
      deployment = ./control.nix;
      config.overrides = {
        kubernetes.modules.control.configuration = {
          number = 1;
        };
      };
    };
    control2 = {
      deployment = ./control.nix;
      config.overrides = {
        kubernetes.modules.control.configuration = {
          number = 2;
        };
      };
    };
  };

  lab2Deployments = recursiveUpdate defaultDeployments {
    control1.config.overrides = {
      kubernetes.modules.control.configuration.ipAddress = "10.35.6.10";
    };
    control2.config.overrides = {
      kubernetes.modules.control.configuration.ipAddress = "10.35.6.11";
    };
  };

  testDeployments = removeAttrs (recursiveUpdate defaultDeployments {
    apiServer.config = {
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
    discovery.config = {
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
    schemaTransformer.config = {
      overrides = {
        kubernetes.modules.schema-transformer.configuration = {
          resources.requests.memory = mkForce "5Mi";
          replicas = mkForce 1;
        };
      };
    };
    svcMonitor.config = {
      overrides = {
        kubernetes.modules.svc-monitor.configuration = {
          resources.requests.memory = mkForce "5Mi";
          replicas = mkForce 1;
        };
      };
    };
    analytics.config = {
      overrides = {
        kubernetes.modules.analytics.configuration = {
          resources.requests.memory = mkForce "5Mi";
          replicas = mkForce 1;
        };
      };
    };
    control1.config = {
      overrides = {
        kubernetes.modules.control.configuration = {
          ipAddress = "10.44.44.50";
          kubernetes.modules.control-1.configuration = {
            resources.requests.memory = mkForce "5Mi";
          };
        };
      };
    };
  }) [ "control2" ];

in {

  lab2 = buildDeployments lab2Deployments;

  test = buildDeployments testDeployments;

}
