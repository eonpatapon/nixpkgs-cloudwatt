{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "memcached-exporter-${version}";
  version = "0.4.1";

  goPackagePath = "github.com/prometheus/memcached_exporter";

  src = fetchFromGitHub {
    rev = "v${version}";
    owner = "prometheus";
    repo = "memcached_exporter";
    sha256 = "04c9y1a0bvvmnfiqlr98cnb3kqxs9bhdqkw1r1w82xgi1s5mlb2x";
  };

  meta = with stdenv.lib; {
    description = "Exports metrics from memcached servers for consumption by Prometheus.";
    homepage = https://github.com/prometheus/memcached_exporter;
    license = licenses.asl20;
    platforms = platforms.unix;
    maintainers = [ maintainers.gespanel ];
  };
}
