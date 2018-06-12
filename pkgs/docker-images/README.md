Docker images definitions
=========================

One service in image
--------------------

Use `lib.buildContrailImageWithPerp` helper:

    locksmithWorker = lib.buildImageWithPerp {
        # name of the image
        name = "locksmith/worker";
        # the base image
        fromImage = lib.images.kubernetesBaseImage;
        # executable that will be run with perp
        command = "${locksmith}/bin/vault-fernet-locksmith";
        # shell commands to be run before running the executable
        preStartScript = "";
    };

Multiple services in the image
------------------------------

Use `lib.buildImageWithPerps` helper:

    gremlinServer = lib.buildImageWithPerps {
        name = "gremlin/server";
        fromImage = lib.images.javaJreImage;
        # list of services to be run by perp
        services = [
          {
            name = "gremlin-server";
            preStartScript = config.gremlin.serverPreStart;
            command = "${contrail32Cw.tools.gremlinServer}/bin/gremlin-server ${config.gremlin.serverConf}";
          }
          {
            name = "gremlin-sync";
            preStartScript = config.gremlin.syncPreStart;
            command = "${contrail32Cw.tools.contrailGremlin}/bin/gremlin-sync";
          }
        ];
    };

Users
-----

By default the `command` will be run with the `nobody` user.

To run the service as `root`, set `user` to `root`:

    image = lib.buildImageWithPerp {
        name = "foo/bar";
        fromImage = lib.images.kubernetesBaseImage;
        command = "${svc}/bin/svc";
        user = "root";
    }

Only `root` and `nobody` users are supported.

Environment
-----------

You can provide an environment file or directory for running the service. See `man runenv 8` for
details. Basically you can provide a file where each line is of type: `var=value`. To provide the
environment to the service, use the `environmentFile` attribute:

    imageEnv = pkgs.writeTextFile {
      name = "env";
      text = ''
        LOG_DEBUG=1
      '';
    }

    image = lib.buildImageWithPerp {
        name = "foo/bar";
        fromImage = lib.images.kubernetesBaseImage;
        command = "${svc}/bin/svc";
        environmentFile = ${imageEnv};
    };

Fluentd integration
-------------------

With `lib.buildImageWithPerps` or `lib.buildImageWithPerp` you can provide a
`fluentd` attribute to enable fluentd in the container as a service run by perp:

    dockerImage = lib.buildImageWithPerp {
        name = "foo/bar";
        fromImage = lib.images.kubernetesBaseImage;
        command = "${service1}/bin/service1";
        fluentd = {
            source = { type = "stdout"; };
        };
    };

With this configuration `stdout` of the command will be captured by fluentd.
The events will by tagged `log.bar` as `bar` is the image name and also the service name.
However it is possible to change the tag by setting a `tag` attribute in the source
definition.

It works with multiple services as well:

    dockerImage = lib.buildImageWithPerps {
        name = "foo/bar";
        fromImage = lib.images.kubernetesBaseImage;
        command = "foo";
        services = [
          {
            name = "service1";
            command = "${service1}/bin/service1";
            fluentd = {
                source = { type = "stdout"; };
            };
          }
          {
            name = "service2";
            command = "${service2}/bin/service2";
            fluentd = {
              source = {
                type = "stdout";
                time_format = "%H:%M:%S.%L";
                format = ''/^(?<time>[^ ]+) (?<classname>[^ ]+) \[(?<level>[^\]]+)\] (?<message>.*)$/'';
              };
            };
          }
        ];

    };

This will start one instance of fluentd configured with 2 sources. First source will be tagged `log.service1`
and the second `log.service2`.

For `service2` we specifiy the format of the logs.

Fluentd source type must be defined. If not no source will be generated for the service.

It is possible to enable fluentd for only one service.

## Regexps in nix

When defining a regexp in `format` for example, use `''` and not `"` to surround the regexp.
With `"`, `\` chars are not preserved.

## Using different sources

The source type `stdout` we have seen before uses in reality the `named_pipe` source
to forward stdout of the process to fluentd. All the plumbing is done in nix. But you
can use other input plugins as you wish.

See https://docs.fluentd.org/v0.12/articles/input-plugin-overview for all available
sources and options available by default in fluentd.

For example to use syslog:

      {
        name = "service2";
        command = "${service2}/bin/service2";
        fluentd = {
          source = {
            type = "syslog";
            port = 1234;
            with_priority = false;
          };
        };
      }

Use the same options names as in fluentd configuration.

### Predefined filters

Only one filter is included by default:

    <filter>
      @type generic_metadata
    </filter>

This filter add some metadata on all log events: container id,
application name, service name, kubernetes pod name...

### Adding custom filters

You can provide additional filters for your service.

    {
      name = "service2";
      command = "${service2}/bin/service2";
      fluentd = {
        source = {
          type = "syslog";
          port = 1234;
        };
        filters = [
          {
            type = "grep";
            regexp = {
              key = "message";
              pattern = "cool";
            };
          }
        ];
      };
    }

This will create this filter:

    <filter log.service2>
      @type grep
      <regexp>
        key message
        pattern cool
      </regexp>
    </filter>

If `tag` attribute is ommited the filter default to `log.{service_name}`. To specify a different tag,
define a `tag` attribute in the filter set. It is demonstrated below.

In the the case of `grep` filter it is possible to define multiple regexp blocks:

    <filter **>
      @type grep
      <regexp>
        key message
        pattern cool
      </regexp>
      <regexp>
        key hostname
        pattern ^web\d+\.example\.com$
      </regexp>
    </filter>

With nix, it is impossible to use the same attribute in sets multiple times.
You can use a list to declare multiple sections with the same tag:

    filters = [
      {
        type = "grep";
        tag = "**";
        regexp = [
          {
            key = "message";
            pattern = "cool";
          }
          {
            key = "hostname";
            pattern = "^web\d+\.example\.com$";
          }
        ];
      }
    ];

### Predefined outputs

Currenlty outputs are not configurable. Here is the default configuration:

    <match log.**>
      @type forward
      # used for v0.12 - v0.14 compatibility
      time_as_integer true
      <server>
        name local
        host fluentd.localdomain
      </server>
    </match>

All events are forwarded to fluentd.localdomain.

### Checking the result configuration

Once you have set your fluentd options, you can build the configuration and
see if it can be loaded by fluentd.

To build the configuration for a particular image (`dockerImages.gremlinFsck` in this case) run:

    $ nix-store --realise $(nix-store -qR $(nix-instantiate -A dockerImages.gremlinFsck) | grep fluentd.conf)
    /nix/store/bx78gynmzmlich02npdkzahm9s6fbxln-fluentd.conf

Then starting `fluentd` with this configuration is quite simple:

    $ nix-build -A fluentdCw
    /nix/store/s5c67mm4ivc64cp723bzwp8zyifnh5ab-fluentd
    $ /nix/store/s5c67mm4ivc64cp723bzwp8zyifnh5ab-fluentd/bin/fluentd -c $(nix-store --realise $(nix-store -qR $(nix-instantiate -A dockerImages.gremlinFsck) | grep fluentd.conf))
    2018-04-04 16:47:20 +0200 [info]: parsing config file is succeeded path="/nix/store/bx78gynmzmlich02npdkzahm9s6fbxln-fluentd.conf"
    [...]

Consul template integration
===========================

A simple consul template integration is provided.

When configured, `consul-template` will be run before any commands that are
defined in `preStartScript`.

You can declaratively provide your template configuration in the `consul`
attribute of any service:

      rec {
        name = "service2";
        command = "${service2}/bin/service2 --conf ${consul.service2.out}";
        consul = lib.consulConf {
          templates = {
            service2 = { srcPath = template; dstFile = "service2.conf"; };
            other = { srcPath = template2; dstPath = "/etc"; dstFile = "otherConf.conf"; };
          };
        };
        preStartScript = ''
            mkdir /var/log/service2;
        '';
      }

Templates are rendered in `/run/consul-template-wrapper` directory. If `dstPath`
is specified a symbolic link is created. You can retrieve the output path of any
template using the `out` attribute.

In the example above the following will be created:

    * /run/consul-template-wrapper/service2.conf
    * /run/consul-template-wrapper/otherConf.conf
    * /etc/otherConf.conf -> /run/consul-template-wrapper/otherConf.conf

Once mode
---------

By default, `consul-template` is run in `once` mode. You can override this behaviour and
provide an action when the template is rendered:

      rec {
        name = "service2";
        consul = lib.consulConf {
          once = false;
          templates = {
            service2 = {
              srcPath = "${template}";
              dstFile = "service2-conf";
              action = "${service2}/bin/service2 --conf ${consul.service2.out}";
            };
          };
        };
      }

In this case, the `command` of the service will be `consul-template` itself.

How Docker images are pushed
============================

In `jobsets.nix`, push expressions are generated for all attributes of
`dockerImages`. Each images is pushed two times to the registry to provide two kind of
tags:
- `commitID-outputSha-imageName`: can be used to find back the commit
  id that produces the image. But it can differ accross CIs since
  different commits can push the same images.
- `outputSha`: this tag is stable accross CIs.

It is recommanded to use the second tag in deployments. But it is
still possible to find back the commit id. By querying the registry
with the tag `outputSha`, it returns all tags of this image (included
the tag `commitID-outputSha-imageName`).
