{ dockerTools }:

{

  kubernetesBaseImage = dockerTools.pullImage {
    imageName = "docker-registry.sec.cloudwatt.com/kubernetes/base";
    imageTag = "16.04-b1536c115472e001";
    sha256 = "0rj1417nn7lmlj9m1l4dsicqrz5y1az7j5v911wfrl590ym57xrb";
  };

  openstackBaseImage = dockerTools.pullImage {
    imageName = "docker-registry.sec.cloudwatt.com/openstack/base";
    imageTag = "16.04-latest";
    sha256 = "1xldf9g0g68962jn52c5ihk5vww92yd38vw6rd7fh5g7xvw231zx";
  };

  keystoneAllImage = dockerTools.pullImage {
    imageName = "r.cwpriv.net/keystone/all";
    imageTag = "9.0.0-61516ea9ed2202a1";
    sha256 = "1z944khvnp0z4mchnkxb5pgm9c29cll5v544jin596pwgrqbcw99";
  };

  calicoNodeImage = dockerTools.pullImage {
    imageName = "quay.io/calico/node";
    imageTag = "v3.1.3";
    sha256 = "1ai16r1fhvgc6lvgxq7b6dnxwb9d3czjxvplv9h7l6l37p2v4wpw";
  };

}
