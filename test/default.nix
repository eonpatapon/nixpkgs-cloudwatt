{ callPackage, contrailPath, contrailPkgs }:

{
  hydra = callPackage ./hydra.nix { };

  fluentd = callPackage ./fluentd.nix { };

  perp = callPackage ./perp.nix { };

  contrailLoadDatabase = callPackage ./contrail-load-database.nix {
    inherit contrailPath contrailPkgs;
  };

  gremlinDump = callPackage ./gremlin-dump.nix {
    inherit contrailPath contrailPkgs;
  };

  infraK8S = callPackage ./infra_k8s.nix { };

  rabbitmqK8S = callPackage ./rabbitmq_k8s.nix { };

  keystoneK8S = callPackage ./keystone_k8s.nix { };

  contrailK8S = callPackage ./contrail_k8s.nix {
    inherit contrailPath contrailPkgs;
  };

  # to run these tests:
  # nix-instantiate --eval --strict -A test.lib
  lib = callPackage ../pkgs/lib/tests.nix { };
}
