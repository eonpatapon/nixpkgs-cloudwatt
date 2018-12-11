{ pkgs, lib, config }:

with builtins;
with pkgs.lib;

rec {

  region = head (splitString "." config.networking.domain);

  fluentdConf = pkgs.writeTextFile {
    name = "fluentd.conf";
    text = ''
      <source>
        @type forward
        bind 169.254.2.1
        port 24224
      </source>
      <match **>
        @type stdout
      </match>
    '';
  };

  calicoPool = pkgs.writeText "pool.json" ( toJSON {
    kind = "IPPool";
    apiVersion = "projectcalico.org/v3";
    metadata = {
      name = "fixed-ips-ippool";
    };
    spec = {
      cidr = "10.44.43.0/24";
      ipipMode = "Never";
      natOutgoing = true;
    };
  });

  calicoctlConf = pkgs.writeTextFile {
    name = "calicoctl.cfg";
    text = ''
      apiVersion: projectcalico.org/v3
      kind: CalicoAPIConfig
      metadata:
      spec:
        datastoreType: "etcdv3"
        etcdEndpoints: "https://etcd.${config.networking.domain}:2379"
        etcdKeyFile: "${certs.master}/etcd-key.pem"
        etcdCertFile: "${certs.master}/etcd.pem"
        etcdCaCertFile: "${certs.master}/ca.pem"
    '';
  };

  calicoResources = pkgs.stdenv.mkDerivation {
    name = "calico-deployment";
    src = pkgs.fetchurl {
      url = "https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/calico.yaml";
      sha256 = "14ad6apsqcwxbprmj98pjxb3mpjmqpqrk0y85krfh1cwjs64nx0s";
    };
    phases = [ "patchPhase" "buildPhase" "installPhase" ];
    # remove install-cni container from calico-node deployment
    patchPhase = ''
      sed '/Calico CNI binaries/,/etcd-certs/d' $src > patched.yaml
    '';
    # convert the yaml file to a json object that can be loaded directly in kubenix
    buildPhase = ''
      ${pkgs.yq}/bin/yq . patched.yaml \
      | ${pkgs.jq}/bin/jq '. | {((.kind | explode | [(.[0] + 32)]+.[1:] | implode) + "s"): {(.metadata.name):.}}' \
      | ${pkgs.jq}/bin/jq -n 'reduce inputs as $i ({}; . * $i)' \
      > resources.json
    '';
    installPhase = ''
      cp resources.json $out
    '';
  };

  k8sStage1Resources = { ... }: with pkgs.dockerImages; {
    kubernetes.resources = mkMerge [
      (pkgs.lib.kubenix.loadJSON calicoResources)
      {
        # Set the VAULT_ADDR variable for all pods
        # Also sets no_proxy variable to not use hard coded https_proxy in consul-template-wrapper
        # This is applied by the kube-bootstrap service
        podPresets.consul-template = {
          spec.env = [
            { name = "VAULT_ADDR"; value = "http://vault.localdomain:8200"; }
            { name = "CONSUL_LOG_LEVEL"; value = "debug"; }
            { name = "no_proxy"; value = "*"; }
          ];
        };
        # Override calico resources
        configMaps.calico-config = {
          data = {
            etcd_endpoints = "https://etcd.${config.networking.domain}:2379";
            etcd_ca = "/calico-secrets/etcd-ca";
            etcd_cert = "/calico-secrets/etcd-cert";
            etcd_key = "/calico-secrets/etcd-key";
          };
        };
        # Setup pool CIDR
        daemonSets.calico-node = {
          spec.template.spec.containers.calico-node = {
            env.CALICO_IPV4POOL_CIDR.value = "10.44.44.0/24";
          };
        };
        # Use our calico-kube-controllers image
        deployments.calico-kube-controllers = {
          spec.selector.matchLabels.k8s-app = "calico-kube-controllers";
          spec.template.spec.securityContext.fsGroup = 65534;
          spec.template.spec.containers.calico-kube-controllers = {
            image = "${calicoKubeControllers.imageName}:${imageHash calicoKubeControllers}";
            env.KUBERNETES_SERVICE_HOST.value = "api.${config.networking.domain}";
          };
        };
      }
    ];
  };

  k8sStage2Resources = { ... }: with pkgs.dockerImages; with pkgs.platforms; {
    kubernetes.resources = {

      configMaps.openstack = mkMerge [
        (pkgs.lib.kubenix.loadYAML (lab2 + /kubernetes/openstack/openstack.configmap.yml))
        { data.region = region; }
      ];

      deployments.kube2consul = mkMerge [
        (pkgs.lib.kubenix.loadYAML (lab2 + /kubernetes/kube2consul/worker.deployment.yml))
        {
          spec.replicas = 1;
          spec.selector.matchLabels.application = "kube2consul";
          spec.template.spec.containers.kube2consul-worker = {
            image = "${kube2consulWorker.imageName}:${imageHash kube2consulWorker}";
            env.KUBERNETES_SERVICE_HOST.value = "api.${config.networking.domain}";
            env.KUBERNETES_SERVICE_PORT.value = "443";
          };
        }
      ];

    };
  };

}
