{ nixpkgs ? <nixpkgs> }:

let bootstrap_pkgs = import nixpkgs {};
in {
  pkgs = bootstrap_pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    # Belong to the branch release-17.09-cloudwatt
    rev = "66b4de79e3841530e6d9c6baf98702aa1f7124e4";
    sha256 = "1l3lwi944hnxka0nfq9a1g86xhc0b8hzqr2fm6cvds33gj26l0g4";};
  contrail = bootstrap_pkgs.fetchFromGitHub {
    owner = "nlewo";
    repo = "nixpkgs-contrail";
    # Belong to the master branch
    rev = "c5a2ca31f3feb956f6f495246441a6e9e75d4b70";
    sha256 = "14v0xqmjyav2l1l47n4gplkwmhhb19962m99x5zi9m91l6n4s4gf";};
  }
