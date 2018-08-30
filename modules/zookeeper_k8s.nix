{ config, lib, pkgs, ... }:

with builtins;
with lib;

let

  cfg = config.zookeeper.k8s;
  port = 2181;

in {

  options.zookeeper.k8s = {

    enable = mkOption {
      type = types.bool;
      default = false;
    };

    aliases = mkOption {
      type = types.listOf types.str;
      description = ''
        Name of services to be registered in consul that
        will point to this service.
      '';
    };


    address = mkOption {
      type = types.str;
      default = "169.254.1.53";
    };

  };

  imports = [
    ./infra_k8s.nix
  ];

  config = mkIf cfg.enable {

    infra.k8s = {
      enable = true;
      externalServices = listToAttrs (
        map (a: nameValuePair a { address = cfg.address; inherit port; }) cfg.aliases
      );
    };

    services.zookeeper = {
      enable = true;
      extraConf = ''
        clientPortAddress=${cfg.address}
      '';
    };

  };

}
