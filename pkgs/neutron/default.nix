{ pkgs, stdenv, python27Packages, fetchgit, contrail32Cw }:

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
    url = "https://github.com/openstack/neutron.git";
    rev = "4d8685da8050df79d9193f91cab572cfc6d67a47";
    sha256 = "17w7skxsjwr1186r5fshd4zq503w402vg27pglhg9y6n4rbs82y6";
    leaveDotGit = true;
  };

  doCheck = false;
  buildInputs = [ pkgs.git ];
  propagatedBuildInputs = builtins.attrValues generated.packages ++ [ ps.contrailNeutronPlugin ];

  meta = with stdenv.lib; {
    maintainers = with maintainers; [ lewo ];
  };
}
# This is then used in the neutron.conf file
// { apiExtensionPath = pkgs.lib.concatStringsSep ":" [
  "extensions:${ps.contrailNeutronPlugin}/lib/python2.7/site-packages/neutron_plugin_contrail/extensions"
  "extensions:${ps.neutron-lbaas}/lib/python2.7/site-packages/neutron_lbaas/extensions" ]; }
