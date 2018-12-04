{ pkgs, lib, config, dockerImages, ... }:

with pkgs.lib;
with dockerImages;

let

  application = "opencontrail";
  vaultPolicy = "opencontrail";
  service = "svc-monitor";
  port = 8088;

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

  kubernetes.modules.svc-monitor = {
    module = "cwDeployment";
    configuration = {
      inherit application service vaultPolicy port;
      image = "${contrailSvcMonitor.imageName}:${imageHash contrailSvcMonitor}";
      livenessProbe = probe;
      readinessProbe = probe;
      resources.limits.memory = "3072Mi";
    };
  };

}
