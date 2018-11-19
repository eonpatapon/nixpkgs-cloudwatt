{ fetched ? import ./nixpkgs-fetch.nix { }
, nixpkgs ? fetched.pkgs
, contrail ? fetched.contrail
}:

let
  toolsOverlay = import (contrail + /tools-overlay.nix);
  contrailOverlay = import (contrail + /contrail-overlay.nix);
  cloudwattOverlay = import ./cloudwatt-overlay.nix;
  ourNixpkgs = import ./nixpkgs-patch.nix nixpkgs;
in import ourNixpkgs { overlays = [ toolsOverlay contrailOverlay cloudwattOverlay ]; }
