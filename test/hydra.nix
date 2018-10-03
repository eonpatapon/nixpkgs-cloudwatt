{ pkgs
, dockerImages
, lib
}:

with import (pkgs.path + /nixos/lib/testing.nix) { system = builtins.currentSystem; };

let
  postgres = pkgs.dockerTools.pullImage {
    imageName = "postgres";
    imageDigest = "sha256:d2376b546ea9de4657a6b73b4fd9911451c0fac23318103b472e5b72240b3401";
    finalImageTag = "9.3";
    sha256 = "0r5yj7y7nisrvzf61zicvj5457bzqb98ydbcl6wra93i1pdgys06";
  };

  runStack = lib.runDockerComposeStack {
    version = "2";
    services = {
      postgres = {
        image = builtins.baseNameOf postgres;
        environment = [ "POSTGRES_PASSWORD=MYPWD" ];
      };
      hydra = {
        image = builtins.baseNameOf dockerImages.hydra;
        environment = [ "HYDRA_DBI=dbi:Pg:dbname=postgres;host=postgres;user=postgres;"
                        "POSTGRES_PASSWORD=MYPWD"
                        "HYDRA_ADMIN_USERNAME=admin"
                        "HYDRA_ADMIN_PASSWORD=admin"
                        "DECL_PROJECT_NAME=cloudwatt"
                        "DECL_FILE=ci/spec.json"
                        "DECL_TYPE=git"
                        "DECL_VALUE=https://github.com/nlewo/nixpkgs-cloudwatt master keepDotGit"
                      ];
        ports = [ "3000:3000" ];
        links = [ "postgres:postgres" ];
      };
    };
  };

  machine = {pkgs, config, ...}: {
    config = rec {
      services.openssh.enable = true;
      services.openssh.permitRootLogin = "yes";
      users.extraUsers.root.password = "root";

      virtualisation = { diskSize = 4960; memorySize = 1024; };
      virtualisation.docker.enable = true;
    };
  };

  testScript =
  ''
    $machine->waitForUnit("network.target");
    $machine->waitForUnit("sockets.target");

    $machine->succeed("${runStack}");

    # We check if the ".jobsets" jobset has been created
    $machine->waitUntilSucceeds('curl -H "Content-Type: application/json" http://localhost:3000/jobset/cloudwatt/.jobsets');
  '';
in
  makeTest { name = "hydra"; nodes = { inherit machine; }; testScript = testScript; }
   // { driverDockerCompose = runStack; }
