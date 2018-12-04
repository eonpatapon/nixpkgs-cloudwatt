{ pkgs, lib }:

with pkgs.lib;

let

  defaultDeployments = {
    hello.deployment = ./hello.nix;
  };

  lab2Deployments = recursiveUpdate defaultDeployments {
    hello.overrides = {
      kubernetes.modules.hello.configuration.image = "lab2-image";
    };
  };

  testDeployments = recursiveUpdate lab2Deployments {
    hello.overrides = {
      kubernetes.modules.hello.configuration.replicas = mkForce 1;
    };
  };

in {

  lab2 = lib.buildK8SDeployments lab2Deployments;

  test = lib.buildK8SDeployments testDeployments;

}
