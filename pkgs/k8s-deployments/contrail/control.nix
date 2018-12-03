{ pkgs, lib, config, dockerImages, ... }:

with pkgs.lib;
with dockerImages;

let

  application = "opencontrail";
  vaultPolicy = "opencontrail";
  port = 8083;

  probe = {
    httpGet.path = "/";
    httpGet.port = port;
    initialDelaySeconds = 160;
    periodSeconds = 30;
    timeoutSeconds = 15;
  };


in {

  require = [
    ../modules/deployment.nix
  ];

  kubernetes.moduleDefinitions.control.module = { name, module, config, ... }: let

    service = "control-${toString config.number}";

  in {

    options = {

      number = mkOption {
        description = "Number of the controller";
        type = types.int;
      };

      ipAddress = mkOption {
        description = "Fixed IP address of the controller";
        type = types.str;
      };

    };

    config = {

      kubernetes.modules."control-${toString config.number}" = {
        module = "cwDeployment";
        configuration = {
          inherit application service vaultPolicy port;
          image = "${contrailControl.imageName}:${imageHash contrailControl}";
          livenessProbe = probe;
          readinessProbe = probe;
          resources.limits.memory = "3072Mi";
          kubernetes.resources.deployments."opencontrail-control-${toString config.number}" = {
            spec.template = {
              spec.hostname = "control-${toString config.number}";
              metadata.annotations = {
                "cni.projectcalico.org/ipAddrs" = ''[ "${config.ipAddress}" ]'';
              };
            };
          };
        };
      };

    };

  };

}
