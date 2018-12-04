{ pkgs }:

let

  callLibs = file: import file { inherit pkgs lib; };

  kubenixSrc = pkgs.fetchFromGitHub {
    owner = "xtruder";
    repo = "kubenix";
    rev = "7287c4ed9ee833ccbce2185038c068bac9c77e7c";
    sha256 = "1f69h31nfpifa6zmgrxiq72cchb6xmrcsy68ig9n8pmrwdag1lgq";
  };

  lib = rec {

    contrail = callLibs ./contrail.nix;
    constants = import ./constants.nix;
    image  = callLibs ./image.nix;
    debian = callLibs ./debian.nix;
    tools = callLibs ./ubuntu-vm.nix;
    fluentd = callLibs ./fluentd.nix;
    trivialBuilders = callLibs ./trivial-builders.nix;
    k8s = callLibs ./k8s.nix;
    kubenix = import kubenixSrc { inherit pkgs; } //
              import (kubenixSrc + /k8s.nix) { inherit pkgs; lib = pkgs.lib; };

    inherit (contrail) buildContrailImageWithPerp buildContrailImageWithPerps;

    inherit (image) buildImageWithPerp buildImageWithPerps runDockerComposeStack
      genPerpRcMain dockerPushImage myIp imageHash;

    inherit (debian) mkDebianPackage publishDebianPkg;

    inherit (tools) runUbuntuVmScript;

    inherit (trivialBuilders) writeConsulTemplateFile writeYamlFile;

    inherit (k8s) buildK8SResources buildK8SDeployments;

  };

in lib
