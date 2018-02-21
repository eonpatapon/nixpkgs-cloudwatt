{ debianPackages, dockerImages, lib, pkgs, stdenv }:

{
  # This build an Ubuntu vm where Debian packages are
  # preinstalled. This is used to easily try generated Debian
  # packages.
  installDebianPackages = lib.runUbuntuVmScript [
    debianPackages.contrailVrouterUbuntu_3_13_0_83_generic
    debianPackages.contrailVrouterUserland
  ];

  loadContrailImages = with dockerImages; pkgs.writeShellScriptBin "load-contrail-images" ''
    for image in ${contrailApi} ${contrailDiscovery} ${contrailControl} ${contrailCollector} ${contrailAnalyticsApi} ${contrailSchemaTransformer} ${contrailSchemaTransformer} ${contrailSvcMonitor} ${contrailVrouter}
    do
      docker load -i $image
    done
  '';

  # This is a dirty helper to quickly push images in a registry for testing
  # For example:
  # $ REGISTRY_USERNAME=jpbraun REGISTRY_PASSWORD=XXXX nix-build --argstr imageName gremlinFsck --argstr namespace jpbraun --argstr dockerRegistry r.cwpriv.net -A tools.pushDockerImage
  pushDockerImage = { dockerRegistry ? "", namespace ? "", imageName ? "" }:
    let
      image = builtins.getAttr imageName dockerImages;
      patched = image // {
        imageName = builtins.concatStringsSep "/" (
          [ namespace ] ++ (builtins.tail (pkgs.lib.splitString "/" image.imageName))
        );
      };
    in
      lib.dockerPushImage dockerRegistry patched "devel";
}
