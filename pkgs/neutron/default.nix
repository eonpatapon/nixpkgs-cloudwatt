{ pkgs, lib, stdenv, python27Packages, fetchgit, contrail32Cw }:

let

generated = import ./requirements.nix { inherit pkgs; };

# The nixpkgs-contrail python package set is overriden to be
# compatible with the python packages used by Neutron.
ps =  pkgs.lib.fix' (
  pkgs.lib.extends (self: super: generated.packages) contrail32Cw.pythonPackages.__unfix__);

in python27Packages.buildPythonApplication {
  version = "mitaka";
  pname = "neutron";

  # prb needs a git repository to get the version
  src = fetchgit {
    url = "${lib.constants.gitUrl}/applications/neutron.git";
    rev = "a5c4bf1f841a0c9e9dcc9b6ddc40b6b851065810";
    sha256 = "0bxrxvm0dmdv3xrfmdy8m0b6nbnnhlr8sbnb79gfvcwp0izv1sly";
    leaveDotGit = true;
  };

  doCheck = false;
  buildInputs = [ pkgs.git ];
  propagatedBuildInputs = builtins.attrValues generated.packages ++ [ ps.contrail_neutron_plugin ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [ lewo ];
  };
}
# This is then used in the neutron.conf file
// { apiExtensionPath = pkgs.lib.concatStringsSep ":" [
  "extensions:${ps.contrail_neutron_plugin}/lib/python2.7/site-packages/neutron_plugin_contrail/extensions"
  "extensions:${ps.neutron-lbaas}/lib/python2.7/site-packages/neutron_lbaas/extensions" ]; }
