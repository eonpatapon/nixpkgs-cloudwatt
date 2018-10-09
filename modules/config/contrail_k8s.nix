{ pkgs }:

with pkgs.lib;

rec {

  images = pkgs.dockerImages;

  application = "opencontrail";
  vaultPolicy = "opencontrail";

  controlIP = "10.44.44.50";
  controlHostname = "control";

  contrailService = service: mkJSONService {
    inherit application service;
  };

  apiDeployment = mkJSONDeployment {
    inherit application vaultPolicy;
    service = "api";
    port = 8082;
    containers = [
      {
        image = "${images.contrailApi.imageName}:${images.contrailApi.imageTag}";
        livenessProbe = mkHTTPGetProbe "/" 8082 15 30 15;
        readinessProbe = mkHTTPGetProbe "/" 8082 15 30 15;
      }
    ];
  };

  schemaTransformerDeployment = mkJSONDeployment {
    inherit application vaultPolicy;
    service = "schema-transformer";
    port = 8087;
    containers = [
      {
        image = "${images.contrailSchemaTransformer.imageName}:${images.contrailSchemaTransformer.imageTag}";
      }
    ];
  };

  svcMonitorDeployment = mkJSONDeployment {
    inherit application vaultPolicy;
    service = "svc-monitor";
    port = 8089;
    containers = [
      {
        image = "${images.contrailSvcMonitor.imageName}:${images.contrailSvcMonitor.imageTag}";
      }
    ];
  };

  analyticsDeployment = mkJSONDeployment {
    inherit application vaultPolicy;
    service = "analytics";
    port = 8081;
    containers = [
      {
        image = "${images.contrailAnalytics.imageName}:${images.contrailAnalytics.imageTag}";
        livenessProbe = mkHTTPGetProbe "/" 8081 30 30 15;
        readinessProbe = mkHTTPGetProbe "/" 8081 30 30 15;
      }
    ];
  };

  discoveryDeployment = mkJSONDeployment {
    inherit application vaultPolicy;
    service = "discovery";
    port = 5998;
    containers = [
      {
        image = "${images.contrailDiscovery.imageName}:${images.contrailDiscovery.imageTag}";
        livenessProbe = mkHTTPGetProbe "/" 5998 30 30 15;
        readinessProbe = mkHTTPGetProbe "/" 5998 30 30 15;
      }
    ];
  };

  controlDeployment = mkJSONDeployment' {
    inherit application vaultPolicy;
    service = "control";
    port = 5269;
    containers = [
      { image = "${images.contrailControl.imageName}:${images.contrailControl.imageTag}"; }
    ];
  } {
    spec = {
      template = {
        spec = {
          hostname = controlHostname;
        };
        metadata = {
          annotations = {
            "cni.projectcalico.org/ipAddrs" = ''["${controlIP}"]'';
          };
        };
      };
    };
  };

}
