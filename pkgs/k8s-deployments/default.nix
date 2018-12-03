{ callPackage, lib, dockerImages }:

with lib;

let

  buildAppDeployment = deployment: { args ? {}, overrides ? {}, filter ? null }: kubenix.buildResources ({
    configuration.imports = [deployment {
      _module.args = {
        inherit dockerImages;
      } // args;
    } overrides];
  } // optionalAttrs (filter != null) {
    resourceFilter = filter;
  });

in {

  contrail = callPackage ./contrail { inherit buildAppDeployment; };

}
