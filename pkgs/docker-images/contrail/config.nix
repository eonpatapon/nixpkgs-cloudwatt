{ pkgs, lib }:

with pkgs.lib;

let

  config = { headers ? "", conf }: ''
    {{ $opencontrail := keyOrDefault "/config/opencontrail/data" "{}" | parseJSON -}}
  '' + headers
     + generators.toINI {} conf;

  logConfig = service: {
    log_level = ''{{- if $opencontrail.${service.name}.log_level }}
                    {{- $opencontrail.${service.name}.log_level }}
                  {{- else if $opencontrail.log_level }}
                    {{- $opencontrail.log_level }}
                  {{- else }}
                    SYS_INFO
                  {{- end }}'';
    log_local = 1;
  };

  ipList = { service, port ? 0, sep ? " "}: ''
    {{- range $index, $data := service "${service}" -}}
      {{- if $index }}${sep}{{ end }}{{- $data.Address -}}${if port > 0 then ":" + toString port else ""}
    {{- end }}'';

  secret = secret: ''
    {{- with secret "secret/opencontrail" -}}
      {{- .Data.${secret} }}
    {{- end }}'';

# Get the list of keys/values of openstack endpoints in JSON format

  catalogOpenstackHeader = ''
    {{ $openstack_region := env "openstack_region" -}}
    {{ $catalog := key (printf "/config/openstack/catalog/%s/data" $openstack_region) | parseJSON -}}
  '';

# Get keystone admin endpoint from the endpoints list in $catalog
  identityAdminHost = ''
    {{ with $catalog.identity.admin_url }}{{ . | regexReplaceAll "http://([^:/]+).*" "$1" }}{{ end }}'';

  cassandraConfig = {
    cassandra_server_list = ipList {
      service = "opencontrail-config-cassandra";
    };
  };

  cassandraAnalyticsConfig = {
    cassandra_server_list = ipList {
      service = "opencontrail-analytics-cassandra";
      port = 9042;
    };
  };

  rabbitConfig = {
    rabbit_server = ipList {
      service = "opencontrail-queue";
      sep = ", ";
    };
    rabbit_port = 5672;
    rabbit_user = "opencontrail";
    rabbit_password = secret "queue_password";
    rabbit_vhost = "opencontrail";
    rabbit_ha_mode = "True";
  };

  zookeeperConfig = {
    zk_server_port = 2181;
    zk_server_ip = ipList {
      service = "opencontrail-config-zookeeper";
      sep = ", ";
    };
  };

  keystoneConfig = {
    auth_host = identityAdminHost;
    auth_port = ''{{ if ($catalog.identity.admin_url | printf "%q") | regexMatch "(http:[^:]+:[0-9]+.*)" }}35357{{ else }}80{{ end }}'';
    auth_protocol = "http";
    admin_tenant_name = "service";
    admin_user = "opencontrail";
    admin_password = secret "service_password";
    region = ''{{ $openstack_region }}'';
  };

  containerIP = ''{{- file "/my-ip" -}}'';

in rec {

  services = {
    api = {
      name = "api";
      dns = "opencontrail-api.service";
      port = 8082;
    };
    ifmap = {
      name = "ifmap";
      dns = "opencontrail-ifmap.service";
      port = 8443;
    };
    discovery = {
      name = "discovery";
      dns = "opencontrail-discovery.service";
      port = 5998;
    };
    schemaTransformer = {
      name = "schema_transformer";
    };
    svcMonitor = {
      name = "svc_monitor";
    };
    control = {
      name = "control";
    };
    collector = {
      name = "collector";
      dns = "opencontrail-collector.service";
      port = 8086;
    };
    analyticsApi = {
      name = "analytics_api";
      dns = "opencontrail-analytics-api.service";
    };
    queryEngine = {
      name = "query_engine";
      dns = "opencontrail-query-engine.service";
    };
  };

  discovery = pkgs.writeTextFile {
    name = "contrail-discovery.conf.ctmpl";
    text = config {
      conf = {
        DEFAULTS = {
          listen_ip_addr = "0.0.0.0";
          listen_port = services.discovery.port;
          # minimim time to allow client to cache service information (seconds)
          ttl_min = 30;
          # maximum time to allow client to cache service information (seconds)
          ttl_max = 80;
          # health check ping interval <=0 for disabling
          hc_interval = 5;
          # maximum hearbeats to miss before server will declare publisher out of service.
          hc_max_miss = 3;
          # use short TTL for agressive rescheduling if all services are not up
          ttl_short = 1;
        }
        // cassandraConfig
        // logConfig services.discovery;

        DNS-SERVER = {
          policy = "fixed";
        };
      };
    };
  };

  api = pkgs.writeTextFile {
    name = "contrail-api.conf.ctmpl";
    text = config {
      headers = catalogOpenstackHeader;
      conf = {
        DEFAULTS = {
          keystone_resync_workers = 10;
          keystone_resync_interval_secs = 86400;
          listen_ip_addr = containerIP;
          sandesh_send_rate_limit = 100;
          # FIXME, the code is publishing ifmap_server_ip instead of listen_ip_addr to the discovery
          ifmap_server_ip = containerIP;
          listen_port = services.api.port;

          disc_server_ip = services.discovery.dns;
          disc_server_port = services.discovery.port;

          vnc_connection_cache_size = 128;

          auth = "keystone";
          aaa_mode = "cloud-admin";
          list_optimization_enabled = "True";
          apply_subnet_host_routes  = "True";
          max_request_size = "2097152";
        }
        // cassandraConfig
        // rabbitConfig
        // zookeeperConfig
        // logConfig services.api;
        KEYSTONE = keystoneConfig;
        IFMAP_SERVER = {
          ifmap_listen_ip = containerIP;
          ifmap_listen_port = services.ifmap.port;
          ifmap_credentials = "api-server" + ":" + secret "ifmap_password";
        };
        QUOTA = {
          virtual_network = 200;
          subnet = 200;
          virtual_machine_interface = 1000;
          logical_router = 200;
          floating_ip = 22;
          security_group = 50;
          security_group_rule = 500;
          loadbalancer_pool = 10;
          virtual_ip = 10;
          loadbalancer_member = 20;
          loadbalancer_healthmonitor = 10;
        };

        NEUTRON = {
          contrail_extensions_enabled = "false";
        };
      };
    };
  };

  schemaTransformer = pkgs.writeTextFile {
    name = "contrail-schema.conf.ctmpl";
    text = config {
      headers = catalogOpenstackHeader;
      conf = {
        DEFAULTS = {
          api_server_ip = services.api.dns;
          disc_server_ip = services.discovery.dns;
          disc_server_port = services.discovery.port;
          sandesh_send_rate_limit = 100;
        }
        // logConfig services.schemaTransformer
        // cassandraConfig
        // rabbitConfig
        // zookeeperConfig;
        KEYSTONE = keystoneConfig;
      };
    };
  };

  svcMonitor = pkgs.writeTextFile {
    name = "contrail-svc-monitor.conf.ctmpl";
    text = config {
      headers = catalogOpenstackHeader;
      conf = {
        DEFAULTS = {
          api_server_ip = services.api.dns;
          disc_server_ip = services.discovery.dns;
          disc_server_port = services.discovery.port;
          check_service_interval = 500;
          sandesh_send_rate_limit = 100;
        }
        // logConfig services.svcMonitor
        // cassandraConfig
        // rabbitConfig
        // zookeeperConfig;
        KEYSTONE = keystoneConfig;
      };
    };
  };

  vncApiLib = pkgs.writeTextFile {
    name = "vnc_api_lib.ini.ctmpl";
    text = config {
      headers = catalogOpenstackHeader;
      conf = {
        auth = {
          AUTHN_TYPE   = "keystone";
          AUTHN_PROTOCOL = "http";
          AUTHN_SERVER = keystoneConfig.auth_host;
          AUTHN_PORT   = keystoneConfig.auth_port;
          AUTHN_URL    = "/v2.0/tokens";
        };
      };
    };
  };


  control = pkgs.writeTextFile {
    name = "contrail-control.conf.ctmpl";
    text = config {
      conf = {
        DEFAULT = logConfig services.control;

        IFMAP = {
          user = "api-server";
          password = secret "ifmap_password";
        };

        DISCOVERY = {
          server = services.discovery.dns;
          port = services.discovery.port;
        };
      };
    };
  };

  collector = pkgs.writeTextFile {
    name = "contrail-collector.conf.ctmpl";
    text = config {
      headers = catalogOpenstackHeader;
      conf = {
        DEFAULT = {
          analytics_data_ttl = 48;
          analytics_flow_ttl = 48;
          analytics_statistics_ttl = 48;
          analytics_config_audit_ttl = 48;
        }
        // logConfig services.collector
        // cassandraAnalyticsConfig;
        KEYSTONE = keystoneConfig;

        COLLECTOR = {
          server = containerIP;
          port = services.collector.port;
        };

        DISCOVERY = {
          server = services.discovery.dns;
          port = services.discovery.port;
        };
      };
    };
  };

  analyticsApi = pkgs.writeTextFile {
    name = "contrail-analytics-api.conf.ctmpl";
    text = config {
      conf = {
        DEFAULT = {
          host_ip = containerIP;
          rest_api_ip = containerIP;
          aaa_mode = "no-auth";
          partitions = 0;
          sandesh_send_rate_limit = 100;
        }
        // logConfig services.analyticsApi
        // cassandraAnalyticsConfig;

        DISCOVERY = {
          disc_server_ip = services.discovery.dns;
          disc_server_port = services.discovery.port;
        };
      };
    };
  };

  queryEngine = pkgs.writeTextFile {
    name = "contrail-query-engine.conf.ctmpl";
    text = config {
      conf = {
        DEFAULT = {
          hostip = containerIP;
          sandesh_send_rate_limit = 100;
        }
        // logConfig services.queryEngine
        // cassandraAnalyticsConfig;

        DISCOVERY = {
          server = services.discovery.dns;
          port = services.discovery.port;
        };
      };
    };
  };

  vrouterAgent = pkgs.writeTextFile {
    name = "contrail-vrouter-agent.conf";
    text = generators.toINI {} {
      DEFAULT = {
        disable_flow_collection = 1;
        log_file = "/var/log/contrail/vrouter.log";
        log_level = "SYS_DEBUG";
        log_local = 1;
      };
      CONTROL-NODE = {
        server = "control";
      };
      DISCOVERY = {
        port = toString services.discovery.port;
        server = "discovery";
      };
      FLOWS = {
        max_vm_flows = 20;
      };
      METADATA = {
        metadata_proxy_secret = "t96a4skwwl63ddk6";
      };
      TASK = {
        tbb_keepawake_timeout = 25;
      };
    };
  };

  vncApiLibVrouter = pkgs.writeTextFile {
    name = "vnc_api_lib.ini";
    text = ''
      [auth]
      AUTHN_TYPE   = keystone
      AUTHN_PROTOCOL = http
      AUTHN_SERVER = identity-admin.dev0.loc.cloudwatt.net
      AUTHN_PORT   = 35357
      AUTHN_URL    = /v2.0/tokens
    '';
  };

  fluentdApiPatterns = [
    {
      format = "regexp";
      expression = {
        regexp = ''/^(?<time>([^ ]+ ){3})[^\:]+:\s+(SANDESH:\s+\[(?<sandesh>[^\]]*)\]\s?)?__default__\s+\[(?<level>[^ ]+)\]:\s+(?<type>VncApiStatsLog):\s+api_stats\s+=\s+<<\s+operation_type\s+=\s+(?<operation_type>\w+)\s+user\s+=\s+(?<user_name>[^ ]+)\s+useragent\s+=\s+(?<useragent>[^ ]+)\s+remote_ip\s+=\s+(?<remote_ip>[^ ]+)\s+domain_name\s+=\s+[^ ]+\s+project_name\s+=\s+(?<project_name>[^ ]+)\s+object_type\s+=\s+(?<object_type>[^ ]+)\s+response_time_in_usec\s+=\s+(?<response_time_in_usec>\d+)\s+response_size\s+=\s+(?<response_size>\d+)\s+resp_code\s+=\s+(?<response_code>\d+).*$/'';
        checks = [
          ''09/06/2018 10:25:12 AM [contrail-api]: __default__ [SYS_INFO]: VncApiStatsLog: api_stats = <<  operation_type = POST  user = neutron  useragent = python-requests/2.9.1  remote_ip = 10.35.8.159  domain_name = default-domain  project_name = service  object_type = logical_router  response_time_in_usec = 3852  response_size = 23  resp_code = 200  >>''
        ];
      };
      time_format = ''%m/%d/%Y %I:%M:%S %p'';
      types = "response_code:integer,response_size:integer,response_time_in_usec:integer";
    }
    {
      format = "regexp";
      expression = {
        regexp = ''/^(?<time>([^ ]+ ){3})[^\:]+:\s+(SANDESH:\s+\[(?<sandesh>[^\]]*)\]\s?)?__default__\s+\[(?<level>[^ ]+)\]:\s+(?<type>VncApiConfigLog):\s+api_log\s+=\s+<<\s+(identifier_uuid\s+=\s+(?<object_uuid>[^ ]+)\s+)?object_type\s+=\s+(?<object_type>[^ ]+)(\s+identifier_name\s+=\s+(?<object_fq_name>[^ ]+))?\s+url\s+=\s+(?<url>[^ ]+)\s+operation\s+=\s+(?<operation_type>[^ ]+)(\s+useragent\s+=\s+(?<useragent>[^ ]+))?(\s+remote_ip\s+=\s+(?<remote_ip>[^ ]+))?(\s+body\s+=\s+(?<body>[^}]+}))?\s+domain\s+=\s+[^ ]+\s+project\s+=\s+(?<project_name>[^ ]+)(\s+user\s+=\s+(?<user_name>[^ ]+))?(\s+error\s+=\s+(?<error>[^>]+))?.*$/'';
        checks = [
          ''09/10/2018 02:29:52 PM [contrail-api]: __default__ [SYS_INFO]: VncApiConfigLog: api_log = <<  identifier_uuid = 60cb686b-cc94-470b-9a35-e2894229184c  object_type = virtual_machine_interface  url = http://127.0.0.1/virtual-machine-interface/60cb686b-cc94-470b-9a35-e2894229184c  operation = http_delete  domain = default-domain  project = service  error = virtual_machine_interface:Delete when resource still referred: ['http://127.0.0.1/loadbalancer/13a87cdf-932f-4ed1-abd9-c99427a95a96']  >>''
          ''09/10/2018 02:30:07 PM [contrail-api]: __default__ [SYS_INFO]: VncApiConfigLog: api_log = <<  identifier_uuid = 462d1948-23d8-4132-bfbf-0b94ab892113  object_type = virtual_network  identifier_name = default-domain:rarora:nginx_vip_net_v2  url = http://127.0.0.1/virtual-network/462d1948-23d8-4132-bfbf-0b94ab892113  operation = delete  domain = default-domain  project = service  >>''
          ''09/10/2018 02:31:35 PM [contrail-api]: __default__ [SYS_INFO]: VncApiConfigLog: api_log = <<  identifier_uuid = 53de7dd1-341b-4021-a48b-58876b56e9df  object_type = service_instance  identifier_name = default-domain:rarora:13a87cdf-932f-4ed1-abd9-c99427a95a96  url = http://contrail-api:8082/service-instance/53de7dd1-341b-4021-a48b-58876b56e9df  operation = delete  useragent = contrail-api-cli  remote_ip = contrail-api:8082  domain = default-domain  project = deployment  user = deployment  >>''
          ''09/10/2018 02:41:36 PM [contrail-api]: __default__ [SYS_INFO]: VncApiConfigLog: api_log = <<  identifier_uuid = 69653ef0-487e-41df-a042-3be0b64c3f4b  object_type = instance_ip  identifier_name = 76d84111-d8c8-40fa-a3d4-fc0af4dc16c9  url = http://contrail-api:8082/ref-update  operation = ref-update  useragent = gremlin-fsck-pods-55b59cb648-wn24f:contrail-api-cli  remote_ip = contrail-api:8082  body = {"ref-type": "virtual-machine-interface", "attr": null, "ref-fq-name": ["default-domain", "rarora", "default-domain__rarora__d9ece944-f160-41ea-8b5e-daf6791be6d1__2__right__1"], "ref-uuid": "3a29e1ee-c1b3-4272-909b-fe86788c2bbe", "operation": "DELETE", "type": "instance-ip", "uuid": "69653ef0-487e-41df-a042-3be0b64c3f4b"}  domain = default-domain  project = deployment  user = deployment  >>''
        ];
      };
      time_format = ''%m/%d/%Y %I:%M:%S %p'';
    }
    {
      format = "regexp";
      expression = {
        regexp = ''/^(?<time>([^ ]+ ){3})[^\:]+:\s+(SANDESH:\s+\[(?<sandesh>[^\]]*)\]\s?)?__default__\s+\[(?<level>[^ ]+)\]:\s+(?<type>VncApiInfo):\s+neutron\s+request\s+\[(?<request_id>[^ ]+)\s+(?<project_id>[^ ]+)\s+(?<user_id>[^ ]+)\]\s+(?<object_op>[^ ]+)\s+(?<object_type>[^ ]+)\s+(?<operation_type>[^ ]+)\s+(?<path>[^ ]+)\s+(?<response_time>[^ ]+).*$/'';
        checks = [
          ''10/10/2018 08:37:41 AM [contrail-api]: __default__ [SYS_INFO]: VncApiInfo: neutron request [req-6200c8be-0177-43b7-b7f4-e34c60711bb0 0ed483e083ef4f7082501fcfa5d98c0e ce6000355ebe4250949c1531631e4544] READALL subnet GET /virtual-networks?count=False&shared=True&obj_uuids=a600d3b2-ba05-4ac0-abbe-1ef617d71f7c,daabd36f-e094-4d65-8906-5f654c8ee1ff,dc14d287-6172-4335-bc83-ec6098586075,ee231665-a5b5-4ec3-92d2-ce62b7491ccb&exclude_hrefs=True&detail=True 0.075468  ''
          ''10/10/2018 08:42:40 AM [contrail-api]: __default__ [SYS_INFO]: VncApiInfo: neutron request [req-6823062f-4c34-4f3a-af6d-400044e583e2 13bbca5ac9fd4d368fca3ee92f920665 1692907117444e1c86316044a5bc7812] DELETE port DELETE /virtual-machine/b6b327a9-2802-4c9f-a4de-c1dfb03ffaba 0.014626  ''
        ];
      };
      time_format = ''%m/%d/%Y %I:%M:%S %p'';
      types = "response_time:float";
    }
  ];

  fluentdForPythonService = { servicePatterns ? [] }: {
    source = {
      type = "stdout";
    };
    filters = [
      # exclude http calls from haproxy checks
      {
        type = "grep";
        exclude = [
          {
            key = "message";
            pattern = {
              regexp = ''^[^ ]*\s+-\s+-\s+\[[^\]]*\]\s+"(GET|HEAD)\s+\/\s+HTTP\/1\.(1|0)"\s+200.*$'';
              checks = [
                ''10.35.9.255 - - [2018-10-03 08:47:24] "GET / HTTP/1.1" 200 18151 0.002356''
                ''10.35.8.179 - - [2018-10-03 08:47:56] "HEAD / HTTP/1.0" 200 130 0.003147''
              ];
            };
          }
        ];
      }
      # exclude sandesh messages
      {
        type = "grep";
        exclude = [
          {
            key = "message";
            pattern = {
              regexp = ''Sandesh Send Level'';
              checks = [
                ''10/10/2018 08:27:41 AM [contrail-schema]: Sandesh Send Level [SYS_DEBUG] -> [INVALID]''
              ];
            };
          }
        ];
      }
      {
        type = "parser";
        key_name = "message";
        parse = {
          type = "multi_format";
          pattern = [
            # bottle logs
            {
              format = "regexp";
              expression = {
                regexp = ''/^(?<remote_ip>[^ ]*)\s+-\s+-\s+\[(?<time>[^\]]*)\]\s+"(?<method>\S+)(?: +(?<path>[^ ]*) +\S*)?"\s+(?<response_code>[^ ]*)\s+(?<response_size>[^ ]*)\s+(?<response_time>\d+.\d+)(.*)?$/'';
                checks = [
                  ''10.35.9.255 - - [2018-09-06 10:25:11] "GET /loadbalancer-healthmonitors?count=False&parent_id=2e71b352-db81-4e47-b350-62ce6f75ee5e&detail=False HTTP/1.1" 200 143 0.007065''
                  ''10.35.8.29 - - [2018-10-10 12:58:19] "POST /publish/opencontrail-api-6dcc7955fb-7n46z HTTP/1.1" 200 167 0.003453''
                ];
              };
              time_format = ''%Y-%m-%d %H:%M:%S'';
              types = "response_code:integer,response_size:integer,response_time:float";
            }
          ] ++ servicePatterns ++ [
            # generic logs for all services
            {
              format = "regexp";
              expression = {
                regexp = ''/^(?<time>([^ ]+ ){3})[^\:]+:\s+(SANDESH:\s+\[(?<sandesh>[^\]]*)\]\s?)?(__default__\s+)?(\[(?<level>[^ ]+)\]:\s+)?((?<type>[^:]+):\s+)?(?<message>.*)$/'';
                checks = [
                  ''09/10/2018 02:50:35 PM [contrail-api]: __default__ [SYS_WARN]: VncApiError: Unknown ID: d70b8b59-e019-4bba-8503-3629c7a78f7a (type: virtual_network)''
                  ''09/10/2018 02:50:11 PM [contrail-api]: __default__ [SYS_NOTICE]: VncApiNotice: chown: 36368b32-c0ae-4be2-a8d3-b72a2039c8ab owner set to 2fd5a201-69cd-4772-b922-2f36c9d82107''
                  ''10/10/2018 12:58:23 PM [contrail-discovery]: __default__ [SYS_INFO]: discServiceLog: <cl=opencontrail-analytics-6cc857cf4d-66kcf:contrail-analytics-api,st=Collector>  subs service=opencontrail-analytics-6cc857cf4d-66kcf, assign=0, count=2''
                  ''10/10/2018 08:25:29 AM [contrail-schema]: Re-add uve <default-domain:tempest1:tempest-private-tempest-1234567,205191> in [ObjectVNTable:UveVirtualNetworkConfigTrace] map''
                  ''10/10/2018 01:05:43 PM [contrail-schema]: Notification Message: {u'oper': u'UPDATE', u'type': u'virtual_router', u'uuid': u'e9d45db2-f8af-40c6-8bda-abb2739302c4'}''
                ];
              };
              time_format = ''%m/%d/%Y %I:%M:%S %p'';
            }
            # fallback
            {
              format = "none";
            }
          ];
        };
      }
    ];
  };

  # Add the name of each analytics service in logs, because in Elasticsearch there is no tag for services
  extraFilters =  [
    {
      type = "record_transformer";
      tag = "";
      record = {
        service_name = "\${tag_parts[1]}";
      };
    }
  ];

  fluentdForCService = { extraFilters ? [] }: {
    source = {
      type = "stdout";
    };
    filters = [
      {
        type = "parser";
        key_name = "message";
        parse = {
          type = "multi_format";
          pattern = [
            {
              format = "regexp";
              expression = ''/^(?<time>[^:]+:[^:]+:[^:]+):[^\[]+\[[^ ]+ (?<thread>[^,]+), [^ ]+(?<pid>[^\]]+)\]: (?<message>.*)$/'';
              time_format = ''%Y-%m-%d %a %H:%M:%S'';
            }
            {
              format = "none";
            }
          ];
        };
      }
    ] ++ extraFilters;
  };
}
