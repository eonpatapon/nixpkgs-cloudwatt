nixpkgs:

let
  pkgs = import nixpkgs {};
in
  pkgs.stdenv.mkDerivation {
    name = "nixpkgs-patched";
    src = nixpkgs;
    patches = [
      # The docker preloader which is merged in 19.03
      (pkgs.fetchpatch {
        url = https://github.com/NixOS/nixpkgs/commit/3fb4eb1c432a4f8cc92965db0e7b2c2856bde596.patch;
        sha256 = "0msiry67mcls9h6v78nfjbv3dzmvqwj8pl32d8jgj0dnz4v0jpvd";
      })
      # Fix docker preloader service. This should be merged upstream. 
      (pkgs.fetchpatch {
        url = https://github.com/nlewo/nixpkgs/commit/539145ad097a3f76aba50a1ff75d9da05623c18c.patch;
        sha256 = "0nii5cx2dgrglqv5727l7vhkprqhjfyl1vz652zw5h05zjd5aym5";
      })
      # Allow to disable clusterCidr in k8s (merged in 19.03)
      (pkgs.fetchpatch {
        url = https://github.com/NixOS/nixpkgs/commit/8264f23f24a43d74b336ca199a3b2aeec4182b48.patch;
        sha256 = "117q456lcrhpnpcc31zdlgf7vl0hdd6z5jkfmrzbkk5yz5656jgx";
      })
      # Fix /etc/hosts for tests
      (pkgs.fetchpatch {
        url = https://github.com/NixOS/nixpkgs/pull/51661/commits/764f16461bd0046b1b264ba8bb700772a137b5a8.patch;
        sha256 = "1kvrc35v2p2yw91allr0n1zjsninz2vsf3jm1p7n0c4k3sqiqiar";
      })
    ];
    installPhase = "cp -r ./ $out/";
    fixupPhase = ":";
  }
