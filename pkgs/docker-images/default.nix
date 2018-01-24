{ pkgs, lib, contrail32Cw }:

let

  configuration = import ./configuration.nix pkgs;

  buildContrailImageWithPerp = name: executable: preStartScript:
    lib.buildImageWithPerp {
      inherit name executable preStartScript;
      fromImage = lib.images.kubernetesBaseImage;
      extraCommands = "chmod u+w etc; mkdir -p var/log/contrail etc/contrail";
  };

  gremlinServerStart = pkgs.writeShellScriptBin "gremlin-server" ''
    export GREMLIN_DUMP_CASSANDRA_SERVERS=opencontrail-config-cassandra.service
    # We can't modify the parent image, so we do it at runtime
    if [ -f /etc/prometheus/prometheus_jmx_java8.yml ] && ! grep -q 'metrics<name'
    then
      echo "- pattern: 'metrics<name=(.+)><>(.+):'" >> /etc/prometheus/prometheus_jmx_java8.yml
    fi
    if [ -f /etc/default/prometheus_jmx ]
    then
      source /etc/default/prometheus_jmx
      export JAVA_OPTIONS="$JAVA_OPTIONS -Dcom.sun.management.jmxremote $PROM_OPTS"
    fi
    ${contrail32Cw.tools.contrailGremlin}/bin/gremlin-dump ${configuration.gremlinDumpPath} && \
    ${contrail32Cw.tools.gremlinServer.gremlinServer}/bin/gremlin-server ${configuration.gremlinServer}
  '';

  gremlinSyncStart = pkgs.writeShellScriptBin "gremlin-sync" ''
    consul-template-wrapper -- -once \
      -template "${configuration.gremlinSync}:/run/consul-template-wrapper/vars" && \
    source /run/consul-template-wrapper/vars && \
    ${contrail32Cw.tools.contrailGremlin}/bin/gremlin-sync
  '';

in
{
  contrailApi = buildContrailImageWithPerp "opencontrail/api"
    "${contrail32Cw.api}/bin/contrail-api --conf_file /etc/contrail/contrail-api.conf"
    ''consul-template-wrapper -- -once  -template="${configuration.api}:/etc/contrail/contrail-api.conf"'';
  contrailDiscovery = buildContrailImageWithPerp "opencontrail/discovery"
    "${contrail32Cw.discovery}/bin/contrail-discovery --conf_file /etc/contrail/contrail-discovery.conf"
    ''consul-template-wrapper -- -once  -template="${configuration.discovery}:/etc/contrail/contrail-discovery.conf"'';
  contrailControl = buildContrailImageWithPerp "opencontrail/control"
    "${contrail32Cw.control}/bin/contrail-control --conf_file /etc/contrail/contrail-control.conf"
    ''consul-template-wrapper -- -once  -template="${configuration.control}:/etc/contrail/contrail-control.conf"'';
  contrailCollector = buildContrailImageWithPerp "opencontrail/collector"
    "${contrail32Cw.collector}/bin/contrail-collector --conf_file /etc/contrail/contrail-collector.conf"
    ''consul-template-wrapper -- -once  -template="${configuration.collector}:/etc/contrail/contrail-collector.conf"'';
  contrailAnalyticsApi = buildContrailImageWithPerp "opencontrail/analytics-api"
    "${contrail32Cw.analyticsApi}/bin/contrail-analytics-api --conf_file /etc/contrail/contrail-analytics-api.conf"
    ''consul-template-wrapper -- -once  -template="${configuration.analytics-api}:/etc/contrail/contrail-analytics-api.conf"'';
  contrailSchemaTransformer = buildContrailImageWithPerp "opencontrail/schema-transformer"
    "${contrail32Cw.schemaTransformer}/bin/contrail-schema --conf_file /etc/contrail/contrail-schema-transformer.conf"
    ''consul-template-wrapper -- -once  -template="${configuration.schema-transformer}:/etc/contrail/contrail-schema-transformer.conf"'';
  contrailSvcMonitor = buildContrailImageWithPerp "opencontrail/svc-monitor"
    "${contrail32Cw.svcMonitor}/bin/contrail-svc-monitor --conf_file /etc/contrail/contrail-svc-monitor.conf"
    ''consul-template-wrapper -- -once  -template="${configuration.svc-monitor}:/etc/contrail/contrail-svc-monitor.conf"'';
  gremlinServer = lib.buildImageWithPerps {
    name = "gremlin/server";
    fromImage = lib.images.javaJreImage;
    services = [
      { name = "gremlin-server"; executable = "${gremlinServerStart}/bin/gremlin-server";
        cwd = "${contrail32Cw.tools.gremlinServer.gremlinServer}/opt"; }
      { name = "gremlin-sync"; executable = "${gremlinSyncStart}/bin/gremlin-sync"; }
    ];
  };
}
