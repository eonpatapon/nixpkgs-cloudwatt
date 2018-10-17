{ hydra, fetchFromGitHub, perlPackages }:

hydra.overrideAttrs(old: {
    name = "hydra-unstable-2018-10-17";
    # Support 9.3 Postgresql
    # Add GitlabPR plugin
    src = fetchFromGitHub {
      owner = "nlewo";
      repo = "hydra";
      rev = "b189e33c699589ac65abae41c672a250e605dcac";
      sha256 = "0nbg6dykz5hippxymbsv1mm0314ar9yv1pnaiy3akj4rzf9lbia5";
    };
    buildInputs = old.buildInputs ++ [ perlPackages.CryptSSLeay ];
})
