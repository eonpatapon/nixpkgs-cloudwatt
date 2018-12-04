{ pkgs, lib, config, dockerImages, ... }:

with pkgs.lib;
with dockerImages;

let

  application = "opencontrail";
  vaultPolicy = "opencontrail";
  service = "analytics";
  port = 8081;

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

  kubernetes.modules.analytics = {
    module = "cwDeployment";
    configuration = {
      inherit application service vaultPolicy port;
      image = "${contrailAnalytics.imageName}:${imageHash contrailAnalytics}";
      replicas = 2;
      livenessProbe = probe;
      readinessProbe = probe;
      resources.limits.memory = "3072Mi";
    };
  };

}
