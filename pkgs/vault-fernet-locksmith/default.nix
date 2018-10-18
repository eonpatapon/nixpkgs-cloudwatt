# This file was generated by https://github.com/kamilchm/go2nix v1.2.1
{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "vault-fernet-locksmith-${version}";
  version = "0.2.2" ;
  rev = "v"+ version ;

  goPackagePath = "github.com/aevox/vault-fernet-locksmith";

  src = fetchFromGitHub {
    inherit rev;
    owner = "aevox";
    repo = "vault-fernet-locksmith";
    sha256 = "03ziwll05xyx2jg01vssqcfs29ngaplj7i0k3gh187v295j8m6km";
  };

  buildFlagsArray = ''
    -ldflags= -X main.locksmithVersion=v${version}'';

  # TODO: add metadata https://nixos.org/nixpkgs/manual/#sec-standard-meta-attributes
  meta = {
  };
}
