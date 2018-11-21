{ hydra, fetchFromGitHub }:

hydra.overrideAttrs(old: {
    name = "hydra-unstable-2018-10-17";
    # Support 9.3 Postgresql
    # Add GitlabPR plugin
    # Add evaluation status
    src = fetchFromGitHub {
      owner = "nlewo";
      repo = "hydra";
      rev = "e92720619e801b58946b53ab093b71cc279260ce";
      sha256 = "00vqdjv4wakl8x4f3x9fkfn4lzg46l521l4hmprhv5vpy9kl3m2f";
    };
})
