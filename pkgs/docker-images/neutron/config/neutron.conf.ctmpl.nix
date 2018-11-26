{ writeText, neutron }:

writeText "neutron.conf.ctmpl.nix" ''
  {{ $openstack_region := env "openstack_region" -}}
  {{ $catalog := key (printf "/config/openstack/catalog/%s/data" $openstack_region) | parseJSON -}}
  {{ $neutron := keyOrDefault "/config/neutron/data" "{}" | parseJSON -}}
  [DEFAULT]
  # to enable debug logs, swap the 2 lines below
  # debug = True
  log_config_append = /etc/neutron/logging.conf

  api_workers = 2
  rpc_workers = 0

  public_endpoint = {{ $catalog.network.public_url }}

  agent_down_time = 75

  allow_overlapping_ips = True

  api_extensions_path = ${neutron.apiExtensionPath}

  core_plugin = neutron_plugin_contrail.plugins.opencontrail.contrail_plugin.NeutronPluginContrailCoreV2
  service_plugins = neutron_plugin_contrail.plugins.opencontrail.loadbalancer.plugin.LoadBalancerPlugin,neutron_plugin_contrail.plugins.opencontrail.loadbalancer.v2.plugin.LoadBalancerPluginV2

  [service_providers]
  service_provider = LOADBALANCER:Haproxy:neutron_plugin_contrail.plugins.opencontrail.loadbalancer.driver.OpencontrailLoadbalancerDriver:default

  [oslo_policy]
  policy_file = policy.cloudwatt.json

  [nova]
  region_name = {{ $openstack_region }}
  endpoint_type = internal
  auth_type = password
  auth_url = {{ $catalog.identity.admin_url }}
  project_name = service
  username = nova
  {{ with secret "secret/nova" -}}
  password = {{ .Data.service_password }}
  {{- end }}

  [quotas]
  quota_driver = neutron_plugin_contrail.plugins.opencontrail.quota.driver.QuotaDriver
  quota_rbac_policy = 0

  [agent]
  report_interval = 30

  [oslo_messaging_notifications]
  driver = messagingv2
''
