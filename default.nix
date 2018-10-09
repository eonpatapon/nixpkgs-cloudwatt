{ fetched ? import ./nixpkgs-fetch.nix { }
, nixpkgs ? fetched.pkgs
, contrail ? fetched.contrail
}:

let
  cloudwatt = import ./cloudwatt-overlay.nix { inherit contrail; };
in import nixpkgs { overlays = [ cloudwatt ]; }
