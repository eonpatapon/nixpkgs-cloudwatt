{ pkgs }:

let

  callLibs = file: import file { inherit pkgs lib; };

  lib = rec {

    contrail = callLibs ./contrail.nix;
    image  = callLibs ./image.nix;
    debian = callLibs ./debian.nix;
    tools = callLibs ./ubuntu-vm.nix;
    fluentd = callLibs ./fluentd.nix;
    trivialBuilders = callLibs ./trivial-builders.nix;
    k8s = callLibs ./k8s.nix;

    inherit (contrail) buildContrailImageWithPerp buildContrailImageWithPerps;

    inherit (image) buildImageWithPerp buildImageWithPerps runDockerComposeStack
      genPerpRcMain dockerPushImage myIp imageHash;

    inherit (debian) mkDebianPackage publishDebianPkg;

    inherit (tools) runUbuntuVmScript;

    inherit (trivialBuilders) writeConsulTemplateFile writeYamlFile;

    inherit (k8s) mkJSONDeployment mkJSONDeployment' mkJSONService mkHTTPGetProbe;
  };

in lib
