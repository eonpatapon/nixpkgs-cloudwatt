{ pkgs, lib, config, dockerImages, ... }:

with pkgs.lib;
with dockerImages;

let

  application = "opencontrail";
  vaultPolicy = "opencontrail";
  service = "schema-transformer";
  port = 8087;

  probe = {
    httpGet.path = "/";
    httpGet.port = port;
    initialDelaySeconds = 15;
    periodSeconds = 30;
    timeoutSeconds = 15;
  };


in {

  require = [
    ../modules/deployment.nix
  ];

  kubernetes.modules.schema-transformer = {
    module = "cwDeployment";
    configuration = {
      inherit application service vaultPolicy port;
      image = "${contrailSchemaTransformer.imageName}:${imageHash contrailSchemaTransformer}";
      livenessProbe = probe;
      readinessProbe = probe;
      resources.limits.memory = "3072Mi";
    };
  };

}
