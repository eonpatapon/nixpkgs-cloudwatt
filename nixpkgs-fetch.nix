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
    rev = "3c627694dfd3717f0a132eca969efb97cfc94be8";
    sha256 = "1gshm81iii3sbcjhr7z2bk8537zzwgqa3501rf4capskpmaihzdl";};
  }
