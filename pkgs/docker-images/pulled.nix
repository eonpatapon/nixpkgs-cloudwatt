{ dockerTools }:

{

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
    imageName = "r.cwpriv.net/keystone/all";
    imageDigest = "sha256:8b69e19bde33a5efc4b24ff46524a0363823265c776f3c66a1b2e5b2a7e64651";
    finalImageTag = "9.0.0-61516ea9ed2202a1";
    sha256 = "0lwkqim968yrz63zamrch6jdilzm7i5j5ag47abk8hqicdkx1502";
  };

  calicoNodeImage = dockerTools.pullImage {
    imageName = "quay.io/calico/node";
    imageDigest = "sha256:a35541153f7695b38afada46843c64a2c546548cd8c171f402621736c6cf3f0b";
    finalImageTag = "v3.1.3";
    sha256 = "0gbqlkn5ajx33ibmad1pmkg3hhqcq2nqxqhaqq80jn6yi6hr74rf";
  };

}
