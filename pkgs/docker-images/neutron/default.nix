{ lib, writeText, stdenv, fetchgit, runCommand, neutron, dockerImages, cwK8sHealthmonitor }:

let
  neutronConf = import ./config/neutron.conf.ctmpl.nix { inherit writeText neutron; };
  authtoken = lib.writeConsulTemplateFile {
    name = "authtoken.conf.ctmpl";
    text = (builtins.readFile ./config/authtoken.conf.ctmpl);
    consulTemplateMocked = builtins.fromJSON (builtins.readFile ./config/mocked-authtoken.conf.ctmpl.json);
  };
  healthMonitorOverrides = lib.writeYamlFile {
    name = "cw-k8s-healthmonitor-overrides.yaml";
    text = ''
      check_plan_overrides:
        neutron-api:
          - ['keystone', null, [ready]]
          - ['http:self', {url: 'http://127.1:9696'}, ['shutdown']]
    '';
  };

  # We don't want to fetch it from git.corp.cloudwatt.net because this
  # cannot be pulled from the sec environment.
  stopContainer = stdenv.mkDerivation {
    name = "stop-container";
    src = fetchgit {
      url = "https://git.sec.cloudwatt.com/docker/openstack-base.git";
      rev = "d92921237f057d802c85e7194bed629a0b5855bd";
      sha256 = "0n3yvlmjj4wg59g4mb7i4gs3b47z18s196cm7av0dd1nv4gfnw3p";
    };
    dontBuild = true;
    installPhase = ''
      install -D resources/usr/lib/openstack-containers/resources/etc/stop-container.d/cw-k8s-healthmonitor $out/usr/sbin/stop-container
    '';
  };

in
lib.buildImageWithPerps {
  name = "openstack/neutron";
  fromImage = dockerImages.pulled.kubernetesBaseImage;
  contents = [
    (runCommand "static-files" {} ''
      mkdir -p $out/etc/
      cp ${./config/policy.cloudwatt.json} $out/etc/policy.cloudwatt.json

      mkdir -p $out/etc/sudoers.d
      cp ${./config/sudo} $out/etc/sudoers.d/neutron

      install -D ${./config/logging.conf} $out/etc/neutron/logging.conf
    '')
    # This is to install neutron config files to /etc/
    neutron
    stopContainer
  ];
  services = [
    {
      name = "neutron-server";
      command = "${neutron}/bin/neutron-server --config-dir /etc/neutron/common.d --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini";
      # FIXME
      user = "root";
      preStartScript = ''
        consul-template-wrapper -- -once \
          -template="${neutronConf}:/etc/neutron/neutron.conf" \
          -template="${authtoken}:/etc/neutron/common.d/authtoken.conf" \
          -template="${./config/contrailplugin.ini.ctmpl}:/etc/neutron/plugin.ini"
      '';
      fluentd = {
        source = {
          type = "stdout";
          format = "/^(?<process>[^ ]+) (?<levelname>[^ ]+) (?<pathname>[^:]+):(?<funcname>[^:]+):(?<lineno>[^ ]+) (?<message>.*)$/";
        };
        matches = [ { type = "openstack_parser"; } ];
      };
   }
   {
     name = "cw-k8s-healthmonitor";
     command = "${cwK8sHealthmonitor}/bin/cw-k8s-healthmonitor --health-monitor-config-file ${healthMonitorOverrides} --graphite-bridge-host graphite-relay.localdomain --component neutron-api";
   }];
}
