{ pkgs, python }:

self: super: rec {
  neutron-lbaas = python.mkDerivation {
    name = "neutron-lbaas-8.3.1";
    src = pkgs.fetchgit {
      url = https://github.com/openstack/neutron-lbaas.git;
      # This is the HEAD of the mitaka-eol branch
      rev = "8d47cdb375b5fa52bea98823bc417100890ffb62";
      sha256 = "0ay47f8aci314n3wmcidhfwz1x8q2x6rarpcy1s8r2vzi8qh95l1";
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
