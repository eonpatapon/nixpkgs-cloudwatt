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
    url = "https://git.corp.cloudwatt.com/applications/neutron.git";
    rev = "7b7c044a3b8f63f2a6a39ddc119dfae706d02ad4";
    sha256 = "1334fkh6jbinry0qvmj1n7ydih17zaas3i7v4apgjb7vs104hhx6";
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
