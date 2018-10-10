{ pkgs, lib, prometheusMemcachedExporter }:

pkgs.dockerTools.buildImage {
  name = "prometheus/memcached-exporter";
  contents = prometheusMemcachedExporter;
  config = {
    Memory = 67108864; #64MB
    ExposedPorts = {"9150/tcp"= {};};
    Cmd = [ "memcached_exporter" ];
  };
}
