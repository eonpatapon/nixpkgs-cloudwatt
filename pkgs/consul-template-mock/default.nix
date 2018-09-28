{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "consul-template-mock-${version}";
  version = "2018-09-24";

  goPackagePath = "github.com/nlewo/consul-template-mock";

  src = fetchFromGitHub {
    owner = "nlewo";
    repo = "consul-template-mock";
    rev = "0c44683f0dffc22d7c04ea8411472f9c152f240b";
    sha256 = "1qpfyf6rz5aikyi2faqqd6nx6cbvgbp441baxhg9kbbhh4gzkmq8";
  };

  meta = with stdenv.lib; {
    homepage = https://github.com/nlewo/consul-template-mock;
    description = "Render consul-template templates without Consul";
    licenses = [ licenses.gpl3 ];
    maintainers = [ maintainers.lewo ];
  };
}
