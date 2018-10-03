{ stdenv, pkgs, python27Packages, fetchgit }:

let
  generated = import ./requirements.nix { inherit pkgs; };
in
python27Packages.buildPythonApplication {
  version = "2018-10-02";
  pname = "cw-k8s-healthmonitor";

  PBR_VERSION = "0.1";

  src = fetchgit {
    url = "https://git.sec.cloudwatt.com/applications/cw_k8s_healthmonitor.git";
    rev = "469c20cd011c5afb40dc1fb92fc1acf0ca4ef5f8";
    sha256 = "0qglk8ac547h4b5hh0midvzs2865f05c7bllnms8508kxp8x2ssw";
  };

  # This will no longer be needed with the next corp/sec git sync
  patchPhase = ''
    sed -i 's/===2.12.5//' requirements.txt
  '';

  doCheck = false;
  propagatedBuildInputs = builtins.attrValues generated.packages;

  meta = with stdenv.lib; {
    maintainers = with maintainers; [ lewo ];
  };
}
