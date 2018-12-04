{ pkgs, lib, config, dockerImages, ... }:

with pkgs.lib;
with dockerImages;
with lib;

let

  application = "opencontrail";
  vaultPolicy = "opencontrail";
  service = "api";
  port = 8082;

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
    ../modules/lb-deployment.nix
  ];

  kubernetes.modules.api = {
    module = "cwDeployment";
    configuration = {
      inherit application service vaultPolicy port;
      image = "${contrailApiServer.imageName}:${imageHash contrailApiServer}";
      replicas = 2;
      livenessProbe = probe;
      readinessProbe = probe;
      resources.limits.memory = "3072Mi";
    };
  };

  kubernetes.modules.api-lb = {
    module = "cwLbDeployment";
    configuration = {
      inherit application service;
    };
  };

}
