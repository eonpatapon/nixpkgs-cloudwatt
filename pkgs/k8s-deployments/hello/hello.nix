{ pkgs, lib, config, dockerImages, ... }:

{

  require = [
    ../modules/deployment.nix
  ];

  kubernetes.modules.hello = {
    module = "cwDeployment";
    configuration = {
      application = "hello";
      service = "test";
      port = 1;
    };
  };

}
