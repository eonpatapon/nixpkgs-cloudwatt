{ pkgs, python }:

self: super: rec {
  neutron-lbaas = python.mkDerivation {
    name = "neutron-lbaas-8.3.1";
    src = pkgs.fetchgit {
      url = https://github.com/openstack/neutron-lbaas.git;
      rev = "659bcebc82d6dba2f792211d205308a4f1bb7116";
      sha256 = "0q6wibalj55sx4924pih6l9v2wvjh0m6clc6ssf57l7v7x4y106b";
      leaveDotGit = true;
    };
    buildInputs = [ pkgs.git ];
    propagatedBuildInputs = [ self.pbr self.pyasn1 self.alembic self."neutron-lib" self."python-barbicanclient" self.pyOpenSSL ];
    doCheck = false;
  };
  
  "jsonschema" = python.overrideDerivation super."jsonschema" (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ pkgs.python27Packages.vcversioner ];
  });

  "oslo.rootwrap" = python.overrideDerivation super."oslo.rootwrap" (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ self.pbr ];
  });

}
