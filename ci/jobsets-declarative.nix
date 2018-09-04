{ nixpkgs, declInput, pulls }:
let
  pkgs = import nixpkgs {};
  prs = builtins.fromJSON (builtins.readFile pulls);
  prJobsets =  pkgs.lib.mapAttrs (num: info:
    { enabled = 1;
      hidden = false;
      description = "PR ${num}: ${info.title}";
      nixexprinput = "cloudwatt";
      nixexprpath = "jobset.nix";
      checkinterval = 30;
      schedulingshares = 20;
      enableemail = false;
      emailoverride = "";
      keepnr = 1;
      inputs = {
        cloudwatt = {
          type = "git";
          value = "${info.source_repo_url} ${info.source_branch} keepDotGit";
          emailresponsible = false;
        };
        bootstrap_pkgs = {
          value = "https://github.com/NixOS/nixpkgs acd89daabcb47cb882bc72ffc2d01281ed1fecb8";
          type = "git";
          emailresponsible = false;
        };
      };
    }
  ) prs;
  desc = prJobsets // {
    trunk = {
      description = "Build master of nixpkgs-cloudwatt";
      checkinterval = "60";
      enabled = "1";
      nixexprinput = "cloudwatt";
      nixexprpath = "jobset.nix";
      schedulingshares = 100;
      enableemail = false;
      emailoverride = "";
      keepnr = 3;
      hidden = false;
      inputs = {
        cloudwatt = {
          value = "https://git.corp.cloudwatt.com/applications/nixpkgs-cloudwatt master keepDotGit";
          type = "git";
          emailresponsible = false;
        };
        bootstrap_pkgs = {
          value = "https://github.com/NixOS/nixpkgs acd89daabcb47cb882bc72ffc2d01281ed1fecb8";
          type = "git";
          emailresponsible = false;
        };
        pushToDockerRegistry = {
          value = "true";
          type = "boolean";
          emailresponsible = false;
        };
        publishToAptly = {
          value = "true";
          type = "boolean";
          emailresponsible = false;
        };
        unsetProxyForAptly = {
          value = "true";
          type = "boolean";
          emailresponsible = false;
        };
      };
    };
    staging = {
      description = "Build master of nixpkgs-cloudwatt and nixpkgs-contrail";
      checkinterval = "60";
      enabled = "1";
      nixexprinput = "cloudwatt";
      nixexprpath = "jobset.nix";
      schedulingshares = 100;
      enableemail = false;
      emailoverride = "";
      keepnr = 1;
      hidden = false;
      inputs = {
        cloudwatt = {
          value = "https://git.corp.cloudwatt.com/applications/nixpkgs-cloudwatt master keepDotGit";
          type = "git";
          emailresponsible = false;
        };
        bootstrap_pkgs = {
          value = "https://github.com/NixOS/nixpkgs acd89daabcb47cb882bc72ffc2d01281ed1fecb8";
          type = "git";
          emailresponsible = false;
        };
        contrail = {
          value = "https://github.com/nlewo/nixpkgs-contrail master";
          type = "git";
          emailresponsible = false;
        };
      };
    };
    testing = {
      description = "Build testing branch of nixpkgs-cloudwatt";
      checkinterval = "60";
      enabled = "1";
      nixexprinput = "cloudwatt";
      nixexprpath = "jobset.nix";
      schedulingshares = 100;
      enableemail = false;
      emailoverride = "";
      keepnr = 1;
      hidden = false;
      inputs = {
        cloudwatt = {
          value = "https://git.corp.cloudwatt.com/applications/nixpkgs-cloudwatt testing keepDotGit";
          type = "git";
          emailresponsible = false;
        };
        bootstrap_pkgs = {
          value = "https://github.com/NixOS/nixpkgs acd89daabcb47cb882bc72ffc2d01281ed1fecb8";
          type = "git";
          emailresponsible = false;
        };
      };
    };
    testingWithPublish = {
      description = "Build the testing-with-publish branch of nixpkgs-cloudwatt";
      checkinterval = "60";
      enabled = "1";
      nixexprinput = "cloudwatt";
      nixexprpath = "jobset.nix";
      schedulingshares = 100;
      enableemail = false;
      emailoverride = "";
      keepnr = 1;
      hidden = false;
      inputs = {
        cloudwatt = {
          value = "https://git.corp.cloudwatt.com/applications/nixpkgs-cloudwatt testing-with-publish keepDotGit";
          type = "git";
          emailresponsible = false;
        };
        bootstrap_pkgs = {
          value = "https://github.com/NixOS/nixpkgs acd89daabcb47cb882bc72ffc2d01281ed1fecb8";
          type = "git";
          emailresponsible = false;
        };
        pushToDockerRegistry = {
          value = "true";
          type = "boolean";
          emailresponsible = false;
        };
        publishToAptly = {
          value = "true";
          type = "boolean";
          emailresponsible = false;
        };
      };
    };
  };

in {
  jobsets = pkgs.runCommand "spec.json" {} ''
    cat <<EOF
    ${builtins.toXML declInput}
    EOF
    cat >$out <<EOF
    ${builtins.toJSON desc} 
    EOF
  '';
}
