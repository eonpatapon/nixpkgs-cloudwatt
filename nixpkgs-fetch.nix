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
    rev = "bde3124fc934d72b095870c099021451eb33f250";
    sha256 = "1nvdrc3r0qfwfhdl5x10has9kiy462f1bf9ga0k8iccsm40shyw6";};
  }
