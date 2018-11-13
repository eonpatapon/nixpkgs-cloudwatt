{ dockerTools }:

rec {

  kubernetesBaseImage = dockerTools.pullImage {
    imageName = "docker-registry.sec.cloudwatt.com/kubernetes/base";
    imageDigest = "sha256:21fca5ffe4b4c4a8b255f90dee92a133346c979a3ebc122104ae91875d06b78f";
    finalImageTag = "16.04-b1536c115472e001";
    sha256 = "0b6dn38vrmvdxindk3gxb858vd84fjybh388cshs9qabrmx10ysw";
  };

  openstackBaseImage = dockerTools.pullImage {
    imageName = "docker-registry.sec.cloudwatt.com/openstack/base";
    imageDigest = "sha256:47bf11f2272ad1ab24c551c102edb4817aa0016cf6954855aef100fbdb0ec288";
    finalImageTag = "16.04-latest";
    sha256 = "1p0fmnhrr5ky8czqbh4bam2iwpkvs9q1q1gd9c66i7cr2x0fhmj8";
  };

  keystoneAllImage = dockerTools.pullImage {
    imageName = "docker-registry.sec.cloudwatt.com/keystone/all";
    imageDigest = "sha256:044d3961a025dc5d29139152ef429934958d25cbc6b6b5f94e4acf83ca5b188e";
    finalImageTag = "11.0.3-4-32e312e4e8b8b842";
    sha256 = "0j6y8bj57kd7qv0wcv0gjql1pnjg52yi4nhl03xhx1diyhh0a2lp";
  };

  # FIXME: remove when patch is included in upstream image
  keystoneAllImagePatched = dockerTools.buildImage {
    name = "openstack/keystone";
    fromImage = keystoneAllImage;
    config = {
      Cmd = [ "/usr/sbin/perpd" ];
      Env = [
        "application=keystone"
        "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/keystone/bin"
      ];
    };
    runAsRoot = ''
      echo "http-keepalive = 5" >> /opt/keystone/etc/uwsgi.ini
    '';
  };

  mcrouterImage = dockerTools.pullImage {
    imageName = "docker-registry.sec.cloudwatt.com/mcrouter/mcrouter";
    imageDigest = "sha256:abedb4c94b5dffb46e723e56cc1753229123b2cd1642dd4d2e7e3992e9e76bdb";
    finalImageTag = "v0.36.0-b9bb358354e806e9";
    sha256 = "15il6bxr7alicqzxc7fazyz5pzrpys332i5kwrxcf1ffj1a72n8s";
  };

  calicoNodeImage = dockerTools.pullImage {
    imageName = "quay.io/calico/node";
    imageDigest = "sha256:c8314fef1eca4fe3f9a17276a53d9a9e141ecd51166fb506d3e2414bda19f7d5";
    finalImageTag = "v3.1.4";
    sha256 = "1yaig1b23dw5kpfl439mm9p8yfq2nir1crpa9yljq60g0m97cpkb";
  };

}
