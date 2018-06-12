{ pkgs, cwPkgs }:

let

  callLibs = file: import file { inherit lib pkgs cwPkgs; };

  lib = rec {

    image  = callLibs ./image.nix;
    images = callLibs ./images.nix;
    debian = callLibs ./debian.nix;
    tools = callLibs ./tools.nix;
    fluentd = callLibs ./fluentd.nix;

    inherit (image) buildImageWithPerp buildImageWithPerps runDockerComposeStack genPerpRcMain dockerPushImage consulConf;

    inherit (debian) mkDebianPackage publishDebianPkg;

    inherit (tools) runUbuntuVmScript;

  };

in lib
