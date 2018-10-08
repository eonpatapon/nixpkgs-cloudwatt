{ stdenv, fetchFromGitHub, go }:

stdenv.mkDerivation rec {
  name = "cni-${version}";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "containernetworking";
    repo = "cni";
    rev = "v${version}";
    sha256 = "1nvixvf5slnsdrfpfs2km64x680wf83jbyp7il12bcim37q2az7m";
  };

  buildInputs = [ go ];

  buildPhase = ''
    patchShebangs build
    ./build
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv bin/* $out/bin
  '';

  meta = with stdenv.lib; {
    description = "Container Network Interface - networking for Linux containers";
    license = licenses.asl20;
    homepage = https://github.com/containernetworking/cni;
    maintainers = [ { github = "eonpatapon"; } ];
    platforms = [ "x86_64-linux" ];
  };
}
