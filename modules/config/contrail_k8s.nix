{ pkgs, cwPkgs, cwLibs }:

rec {

  images = cwPkgs.dockerImages;

  application = "opencontrail";
  vaultPolicy = "opencontrail";

  controlIP = "10.44.44.50";
  controlHostname = "control";

  contrailService = service: cwLibs.mkJSONService {
    inherit application service;
  };

  apiDeployment = cwLibs.mkJSONDeployment {
    inherit application vaultPolicy;
    service = "api";
    port = 8082;
    containers = [
      {
        image = "${images.contrailApi.imageName}:${images.contrailApi.imageTag}";
        livenessProbe = cwLibs.mkHTTPGetProbe "/" 8082 15 30 15;
        readinessProbe = cwLibs.mkHTTPGetProbe "/" 8082 15 30 15;
      }
    ];
  };

  schemaTransformerDeployment = cwLibs.mkJSONDeployment {
    inherit application vaultPolicy;
    service = "schema-transformer";
    port = 8087;
    containers = [
      {
        image = "${images.contrailSchemaTransformer.imageName}:${images.contrailSchemaTransformer.imageTag}";
      }
    ];
  };

  svcMonitorDeployment = cwLibs.mkJSONDeployment {
    inherit application vaultPolicy;
    service = "svc-monitor";
    port = 8089;
    containers = [
      {
        image = "${images.contrailSvcMonitor.imageName}:${images.contrailSvcMonitor.imageTag}";
      }
    ];
  };

  analyticsDeployment = cwLibs.mkJSONDeployment {
    inherit application vaultPolicy;
    service = "analytics";
    port = 8081;
    containers = [
      {
        image = "${images.contrailAnalytics.imageName}:${images.contrailAnalytics.imageTag}";
        livenessProbe = cwLibs.mkHTTPGetProbe "/" 8081 30 30 15;
        readinessProbe = cwLibs.mkHTTPGetProbe "/" 8081 30 30 15;
      }
    ];
  };

  discoveryDeployment = cwLibs.mkJSONDeployment {
    inherit application vaultPolicy;
    service = "discovery";
    port = 5998;
    containers = [
      {
        image = "${images.contrailDiscovery.imageName}:${images.contrailDiscovery.imageTag}";
        livenessProbe = cwLibs.mkHTTPGetProbe "/" 5998 30 30 15;
        readinessProbe = cwLibs.mkHTTPGetProbe "/" 5998 30 30 15;
      }
    ];
  };

  controlDeployment = cwLibs.mkJSONDeployment' {
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
