{ fetched ? import ./nixpkgs-fetch.nix { }
, nixpkgs ? fetched.pkgs
, contrail ? fetched.contrail
}:

let
  cloudwatt = import ./cloudwatt-overlay.nix { inherit contrail; };
  ourNixpkgs = import ./nixpkgs-patch.nix nixpkgs;
in import ourNixpkgs { overlays = [ cloudwatt ]; }
