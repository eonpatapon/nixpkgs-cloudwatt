# Cloudwatt Nix Expressions

## Setup

### Install nix

    % curl https://nixos.org/nix/install | sh

And follow instructions.

See https://nixos.org/nix/download.html for more informations.

### Nix configuration

Add this nix configuration to `~/.config/nix/nix.conf`:

    substituters = https://cache.nixos.org http://84.39.63.212 http://nix-cache.int0.aub.cloudwatt.net
    trusted-substituters = http://84.39.63.212 http://nix-cache.int0.aub.cloudwatt.net
    trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= hydra:dUe+CfbBeef0GlMXllmA0D5Mv3yR7wtUwZ6Oy/+0zOo= cache.opencontrail.org:OWF7nfkyJEPX4jYvOrcuelFUH4njVRJ6SDM6+xlFUOQ=

This is for using our binary caches.

 * http://84.39.63.212 is the cache of nixpkgs-contrail, it is public
 * http://nix-cache.int0.aub.cloudwatt.net is the cache of nixpkgs-cloudwatt, you need VPN access

### Nix bash completion (optional)

Ensure you have `bash-completion` package installed with your distro. Then:

    % nix-env -iA nixpkgs.nix-bash-completions

Then add the following to your `.bashrc` and open a new shell:

    source $HOME/.nix-profile/share/bash-completion/completions/_nix

If everything goes right this should work:

    % cd /path/to/nixpkgs-cloudwatt
    % nix-build -A test.<tab>
    test.contrailK8S           test.gremlinDump           test.keystoneK8S           test.perp
    test.contrailLoadDatabase  ...

## Layout

This package set layout is:

    pkgs
    |---- perp
    |---- pileus
    |---- fluentd
    |---- ... (applications)
    |
    |---- contrail32Cw
    |     |---- apiServer
    |     |---- ...
    |
    |---- debianPackages
    |     |---- contrailVrouterAgent
    |     |---- ...
    |
    |     dockerImages
    |     |---- locksmithWorker
    |     |---- contrailApiServer
    |     |---- ...
    |
    |---- test
    |     |---- perp
    |     |---- keystoneK8S
    |     |---- ...
    |
    |---- tools

## Other docs

 * [Docker images build](dockerImages/README.md)
 * [Contrail vrouter build](doc/vrouter.md)
 * [Debian packages](doc/debian.md)
 * [Hydra jobs](doc/hydra.md)
 * [Adding fluentd plugins](pkgs/fluentd/README.md)
 * [CI build](ci/README.md)

## Some Usage Examples

### List attributes

Root attributess are `contrail32Cw`, `debianPackages`, `dockerImages`...

See [cloudwatt-overlay.nix](cloudwatt-overlay.nix) to see all root attributes.

For instance, to list all docker images:

    % nix-env -f default.nix -qaP -A dockerImages
    dockerImages.contrailAnalytics            docker-image-analytics.tar.gz
    dockerImages.skydiveAnalyzer              docker-image-analyzer.tar.gz
    ...

### Build a docker image

    % nix-build -A dockerImages.locksmithWorker
    % docker load -i result

### Running a test

    % nix-build -A test.perp
    % firefox result/log.html

### Running the test VM interactively

    % nix-build -A test.perp.driver
    # redirect local port 2222 to VM port 22
    % QEMU_NET_OPTS="hostfwd=tcp::2222-:22" ./result/bin/nixos-run-vms
    % ssh -p 2222 root@localhost

### Push an image in a private namespace for testing purposes

First create an account on https://portus.corp.cloudwatt.com/.

Must be done only once:

    % docker login r.cwpriv.net
    % nix-build -A tools.pushImage
    /nix/store/ppl41l4j6v5drdzk80676vvknnv9627b-push-image
    % nix-env -i /nix/store/ppl41l4j6v5drdzk80676vvknnv9627b-push-image

Then you can build any image, and upload it to you personal namespace in the registry:

    % nix-build -A dockerImages.locksmithWorker
    /nix/store/ihnp71p3gxlj9qf41pgs677prjv11q1w-docker-image-worker.tar.gz
    % push-image /nix/store/ihnp71p3gxlj9qf41pgs677prjv11q1w-docker-image-worker.tar.gz jpbraun/locksmith:latest
    Getting image source signatures
    Copying blob sha256:b8d4d3025a405886d28d1978ccbb3b930c465d376353ec4d6aa016991f5eaad3
     85.16 MB / 85.16 MB [=========================================================]
    Copying blob sha256:34418e226e96622b1156e74c904f1e60089d04baa535939e5a36b41bdcfb1002
    [...]

## How external repositories are managed

Expressions from the `nixpkgs` and `nixpkgs-contrail` repositories are
required to build expressions. The file `nixpkgs-fetch.nix` specifies
the commits id that we use by default.

For instance, `nix-build -A contrail32.apiServer` builds the
`contrail-api-server` by using commits id specified in [nixpkgs-fetch.nix](nixpkgs-fetch.nix).

You can easily override them:

    % nix-build -A contrail32.apiServer --arg contrail /path/to/nixpgs-contrail.git \
        --arg nixpkgs /path/to/nixpkgs.git
