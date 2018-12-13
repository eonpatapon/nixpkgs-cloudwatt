self: super:
let inherit (super) callPackage callPackages;
in {

  lib = (super.lib or {}) // (import ./pkgs/lib { pkgs = self; });

  perp = callPackage ./pkgs/perp { };

  fluentd = callPackage ./pkgs/fluentd { };

  fluentdCw = callPackage ./pkgs/fluentdCw { };

  fluentdRegexpTester = callPackage ./pkgs/fluentd-regexp-tester { };

  vaulttmpfs = callPackage ./pkgs/kubernetes-flexvolume-vault-plugin { };

  calicoCniPlugin = callPackage ./pkgs/calicoCniPlugin { };

  cni_0_3_0 = callPackage ./pkgs/cni { };

  consulTemplateMock = callPackage ./pkgs/consul-template-mock { };

  contrail32Cw = callPackage ./pkgs/contrail32Cw { };

  cwK8sHealthmonitor = callPackages ./pkgs/cw-k8s-healthmonitor { };

  debianPackages = callPackages ./pkgs/debian-packages {
    contrailPkgs = self.contrail32Cw;
    skydive = self.skydive.override (_: { enableStatic = true; });
  };

  dockerImages = callPackages ./pkgs/docker-images { };

  k8sDeployments = callPackage ./pkgs/k8s-deployments { };

  hydra = callPackages ./pkgs/hydra { hydra = super.hydra; };

  tools = callPackages ./pkgs/tools { };

  neutron = callPackage ./pkgs/neutron { };

  locksmith = callPackage ./pkgs/vault-fernet-locksmith { };

  kube2consul = callPackage ./pkgs/kube2consul { };

  calicoKubeControllers = callPackage ./pkgs/calico-kube-controllers { };

  skydive = callPackage ./pkgs/skydive { };

  waitFor = callPackage ./pkgs/wait-for { };

  openstackClient = callPackage ./pkgs/openstackclient { };

  calicoctl = callPackage ./pkgs/calicoctl { };

  test = callPackages ./test { };

  ubuntuKernelHeaders = callPackages ./pkgs/ubuntu-kernel-headers { };

  prometheusMemcachedExporter = callPackages ./pkgs/prometheus-memcached-exporter { };

  platforms = callPackages ./pkgs/platforms { };

}