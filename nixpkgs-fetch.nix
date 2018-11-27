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
    rev = "3ef18ec0df18f8d6d4c084f9c6dc1d26ee17f234";
    sha256 = "0xpqfhgxlnicvxx72xxn31r0c7bfgpgf96lksqd42x4rga0dvlyg";};
  }
