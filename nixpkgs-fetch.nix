{ nixpkgs ? <nixpkgs> }:

let bootstrap_pkgs = import nixpkgs {};
in {
  pkgs = bootstrap_pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    # Belong to the branch release-18.09
    rev = "094ff6cf6a9b97e4963f1bc99104bc71a5063371";
    sha256 = "17930p3f5a9i0mmdhpwqgb3gm6zyk1xfj5hhqrfcfp80c7rrq17s";};
  contrail = bootstrap_pkgs.fetchFromGitHub {
    owner = "nlewo";
    repo = "nixpkgs-contrail";
    # Belong to the master branch
    rev = "9e5a12ce900e7dc2fa67558cc3f60760050cd7bb";
    sha256 = "11flcibqwzfkz80gyx6fchviwpcyk7w0hi5mzls2wzh62kg6d6f5";};
  }
