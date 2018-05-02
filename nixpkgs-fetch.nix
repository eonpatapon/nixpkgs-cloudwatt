{ nixpkgs ? <nixpkgs> }:

let bootstrap_pkgs = import nixpkgs {};
in {
  pkgs = bootstrap_pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    # Belong to the branch release-18.03
    rev = "32f08fe6c502d04b6350364a626634d425706bb1";
    sha256 = "0fjv0xbwqsajbil9vxlqkqf1iffr5f6cil0cc5wa5xwi7bm1rm9s";};
  contrail = bootstrap_pkgs.fetchFromGitHub {
    owner = "nlewo";
    repo = "nixpkgs-contrail";
    # Belong to the master branch
    rev = "7ff6eaaa820e8a2d57497fdb338a28f107079862";
    sha256 = "0rnbvs26g7bw41rmldvbwlbs5bs0p6da85fcx3nlapm79ic68n7h";};
  }
