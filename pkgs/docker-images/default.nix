{ callPackage, callPackages, contrailPath }:

callPackages ./contrail { inherit contrailPath; } //
{
  hydra = callPackage ./hydra { };

  locksmithWorker = callPackage ./locksmithWorker { };

  kube2consulWorker = callPackage ./kube2consulWorker { };

  calicoKubeControllers = callPackage ./calico-kube-controllers { };

  gremlinServer = callPackage ./gremlin-server { };

  gremlinFsck = callPackage ./gremlin-fsck { };

  neutron = callPackage ./neutron { };

  skydiveAnalyzer = callPackage ./skydive { };

  pulled = callPackages ./pulled.nix { };
}
