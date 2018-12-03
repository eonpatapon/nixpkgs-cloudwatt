{ pkgs, lib, config, dockerImages, ... }:

with dockerImages;
with pkgs.lib;

let

  application = "opencontrail";
  vaultPolicy = "opencontrail";
  service = "discovery";
  port = 5998;

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

  kubernetes.modules.discovery = {
    module = "cwDeployment";
    configuration = {
      inherit application service vaultPolicy port;
      image = "${contrailDiscovery.imageName}:${imageHash contrailDiscovery}";
      replicas = 2;
      livenessProbe = probe;
      readinessProbe = probe;
      resources.limits.memory = "3072Mi";
    };
  };

  kubernetes.modules.discovery-lb = {
    module = "cwLbDeployment";
    configuration = {
      inherit application service;
    };
  };

}
