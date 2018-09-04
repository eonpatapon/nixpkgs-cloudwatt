{ nixpkgs ? <nixpkgs> }:

let bootstrap_pkgs = import nixpkgs {};
in {
  pkgs = bootstrap_pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    # Belong to the branch release-18.03
    rev = "6796f5db1c2a25aeade10d613ddb403e4eb7a928";
    sha256 = "0fmvh1wcr1rgsr6cv8bpw5rmm9ypg94q7h9s4xqzaq567d3nhhhz";};
  contrail = bootstrap_pkgs.fetchFromGitHub {
    owner = "nlewo";
    repo = "nixpkgs-contrail";
    # Belong to the master branch
    rev = "86140b3eaa6dd771767ecf83426d84e66523f740";
    sha256 = "1d87dijzx043l4kldgd6fz2105a27498m60iajz9amg05rksfrds";};
  }
