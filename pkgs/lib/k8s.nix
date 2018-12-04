{ pkgs, lib }:

with pkgs.lib;

rec {

  buildK8SResources = configuration: lib.kubenix.buildResources { inherit configuration; };

  buildK8SDeployments = deployments:
    let
      deploymentFiles = mapAttrs (_: d: buildK8SDeployment d) deployments;
      toSnakeCase = s:
        concatStrings (map (c: if elem c upperChars then "-${toLower c}" else c) (stringToCharacters s));
      toYAML = n: f: "cat ${f} | yq . -y > ${toSnakeCase n}.yml";
    in pkgs.stdenv.mkDerivation {
      name = "deployment";
      phases = [ "buildPhase" "installPhase" ];
      buildInputs = with pkgs; [ yq ];
      buildPhase = concatStringsSep "\n" (mapAttrsToList toYAML deploymentFiles);
      installPhase = "mkdir $out && cp ./*.yml $out";
    };

  buildK8SDeployment = { deployment, args ? {}, overrides ? {}, filter ? null }:
    kubenix.buildResources ({
      configuration.imports = [deployment {
        _module.args = {
          dockerImages = pkgs.dockerImages;
        } // args;
      } overrides];
    } // optionalAttrs (filter != null) {
      resourceFilter = filter;
    });

}
