{ pkgs, stdenv, python27Packages, fetchgit }:

let generated = import ./requirements.nix { inherit pkgs; };
in python27Packages.buildPythonPackage rec {
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
  propagatedBuildInputs = builtins.attrValues generated.packages;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [ lewo ];
  };
}
