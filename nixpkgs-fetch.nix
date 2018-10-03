{ nixpkgs ? <nixpkgs> }:

let bootstrap_pkgs = import nixpkgs {};
in {
  pkgs = bootstrap_pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    # Belong to the branch release-18.09
    rev = "f12ea6195e4819586ee174d4ef9113b2c1007045";
    sha256 = "07fj3bdq38fcab7acfv0ynxc849g98fd0a671apmjzfbqjg7bm68";};
  contrail = bootstrap_pkgs.fetchFromGitHub {
    owner = "nlewo";
    repo = "nixpkgs-contrail";
    # Belong to the master branch
    rev = "fde2d065b42ea4bbb81f1e8030d5d42a57e3e600";
    sha256 = "1j7izgpw3ag67bgy36s2a4cxlzapw9gy4713gcfh0jwwzkkixzr1";};
  }
