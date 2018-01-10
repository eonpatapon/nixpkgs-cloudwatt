{ fetched ? import ./nixpkgs-fetch.nix {}
, nixpkgs ? fetched.pkgs
, contrail ? fetched.contrail
}:

let pkgs = import nixpkgs {};
    lib =  import ./lib pkgs;

    allPackages = import (contrail + "/all-packages.nix") { inherit pkgs nixpkgs; };

    # Override sources attribute to use the Cloudwatt repositories instead of Contrail repositories
    overrideContrailPkgs = self: super: {
      sources = super.sources32 // (import ./sources.nix { inherit pkgs; });
      contrailVersion = self.contrail32;
      thirdPartyCache = super.thirdPartyCache.overrideAttrs(oldAttrs:
        { outputHash = "1rvj0dkaw4jbgmr5rkdw02s1krw1307220iwmf2j0p0485p7d3h2"; });
    };
    contrailPkgsCw = pkgs.lib.fix (pkgs.lib.extends overrideContrailPkgs allPackages);

    configuration = import ./configuration.nix pkgs;

    buildContrailImageWithPerp = name: command:
      lib.buildImageWithPerp {
        inherit name command;
        extraCommands = "mkdir -p var/log/contrail";
      };

in rec {
  ci.hydraImage = import ./ci {inherit pkgs;};
 
  contrail32Cw = with contrailPkgsCw; {
    inherit api control vrouterAgent
            collector analyticsApi discovery
            queryEngine schemaTransformer svcMonitor
            configUtils vrouterUtils
            vrouterNetns vrouterPortControl
            webCore
            test
            vms;
  };

  images = {
    contrailApi = buildContrailImageWithPerp "opencontrail/apiToTestSecret"
      "${contrail32Cw.api}/bin/contrail-api --conf_file ${configuration.api}";
    contrailDiscovery = buildContrailImageWithPerp "opencontrail/discovery"
      "${contrail32Cw.discovery}/bin/contrail-discovery --conf_file ${configuration.discovery}";
    contrailControl = buildContrailImageWithPerp "opencontrail/control"
      "${contrail32Cw.control}/bin/contrail-control --conf_file ${configuration.control}";
    contrailCollector = buildContrailImageWithPerp "opencontrail/collector"
      "${contrail32Cw.collector}/bin/contrail-collector --conf_file ${configuration.collector}";
    contrailAnalyticsApi = buildContrailImageWithPerp "opencontrail/analytics-api"
      "${contrail32Cw.analyticsApi}/bin/contrail-analytics-api --conf_file ${configuration.analytics-api}";
    contrailSchemaTransformer = buildContrailImageWithPerp "opencontrail/schema-transformer"
      "${contrail32Cw.schemaTransformer}/bin/contrail-schema --conf_file ${configuration.schema-transformer}";   
    contrailSvcMonitor = buildContrailImageWithPerp "opencontrail/svc-monitor"
      "${contrail32Cw.svcMonitor}/bin/contrail-svc-monitor --conf_file ${configuration.svc-monitor}";
  };

  debianPackages = import ./debian-packages.nix { contrailPkgs=contrailPkgsCw; inherit pkgs; };

  # This build an Ubuntu vm where Debian packages are
  # preinstalled. This is used to easily try generated Debian
  # packages.
  tools.installDebianPackages = lib.runUbuntuVmScript [
    debianPackages.contrailVrouterUbuntu_3_13_0_83_generic
    debianPackages.contrailVrouterUserland
  ];

  vaultSync = pkgs.callPackage ./pkgs/vault-sync {};

  vaultSyncImagePerp = lib.buildImageWithPerp {
    name = "vault-sync";
    command = "${vaultSync}/bin/vault-sync";
  };
}

