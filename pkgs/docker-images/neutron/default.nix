{ lib, writeText, runCommand, neutron, dockerImages }:

let
  neutronConf = import ./config/neutron.conf.ctmpl.nix { inherit writeText neutron; };

in
lib.buildImageWithPerp {
  name = "openstack/neutron";
  fromImage = dockerImages.pulled.openstackBaseImage;
  command = "${neutron}/bin/neutron-server --config-dir /etc/neutron/common.d --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini";
  contents = [
    (runCommand "static-files" {} ''
      mkdir -p $out/etc/
      cp ${./config/policy.cloudwatt.json} $out/etc/policy.cloudwatt.json

      mkdir -p $out/etc/sudoers.d
      cp ${./config/sudo} $out/etc/sudoers.d/neutron
    '')
    # This is to install neutron config files to /etc/
    neutron
  ];
  # FIXME
  user = "root";
  preStartScript = ''
    consul-template-wrapper -- -once \
      -template="${neutronConf}:/etc/neutron/neutron.conf" \
      -template="${./config/authtoken.conf.ctmpl}:/etc/neutron/common.d/authtoken.conf" \
      -template="${./config/queue.conf.ctmpl}:/etc/neutron/common.d/queue.conf" \
      -template="${./config/contrailplugin.ini.ctmpl}:/etc/neutron/plugin.ini" \
      -template="/etc/consul-template/openstack/logging.conf.ctmpl:/etc/neutron/logging.conf"
  '';
}
