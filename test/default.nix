{ callPackage, contrail32Cw }:

{
  hydra = callPackage ./hydra.nix { };

  fluentd = callPackage ./fluentd.nix { };

  perp = callPackage ./perp.nix { };

  contrailLoadDatabase = callPackage ./contrail-load-database.nix { contrailPkgs = contrail32Cw; };

  gremlinDump = callPackage ./gremlin-dump.nix { contrailPkgs = contrail32Cw; };

  infraK8S = callPackage ./infra_k8s.nix { };

  infraMultiK8S = callPackage ./infra_multi_k8s.nix { };

  rabbitmqK8S = callPackage ./rabbitmq_k8s.nix { };

  keystoneK8S = callPackage ./keystone_k8s.nix { };

  neutronK8S = callPackage ./neutron_k8s.nix { contrailPkgs = contrail32Cw; };

  contrailK8S = callPackage ./contrail_k8s.nix { contrailPkgs = contrail32Cw; };

  # to run these tests:
  # nix-instantiate --eval --strict -A test.lib
  lib = callPackage ../pkgs/lib/tests.nix { };
}
