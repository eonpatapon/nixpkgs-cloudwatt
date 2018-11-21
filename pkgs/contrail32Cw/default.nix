{ callPackage, pkgs, contrail32, ubuntuKernelHeaders }:

with ubuntuKernelHeaders;

let

  prd1CassandraDump = pkgs.fetchzip {
    name = "prd1-cassandra-dump";
    url = http://nexus.int0.aub.cloudwatt.net/nexus/content/sites/nix/cassandra-dump-prd1-2018-11-19.tgz;
    sha256 = "0lg5yif95vqiw588gnppadssjhci5kp3ii1279ifrvz6h6pg5kn4";
    stripRoot = false;
  };

  prd2CassandraDump = pkgs.fetchzip {
    name = "prd2-cassandra-dump";
    url = http://nexus.int0.aub.cloudwatt.net/nexus/content/sites/nix/cassandra-dump-prd2-2018-11-21.tgz;
    sha256 = "0qjk1f37r4wjk2ibk89ylmfdk552zadiwpal8gxs1bb554z0kb72";
    stripRoot = false;
  };

in

  contrail32.overrideScope' (self: super: {
    contrailSources = super.contrailSources // (callPackage ./sources.nix { });
    vrouter_ubuntu_3_13_0_83_generic = self.lib.buildVrouter ubuntuKernelHeaders_3_13_0_83_generic;
    vrouter_ubuntu_3_13_0_112_generic = self.lib.buildVrouter ubuntuKernelHeaders_3_13_0_112_generic;
    vrouter_ubuntu_3_13_0_125_generic = self.lib.buildVrouter ubuntuKernelHeaders_3_13_0_125_generic;
    vrouter_ubuntu_3_13_0_141_generic = self.lib.buildVrouter ubuntuKernelHeaders_3_13_0_141_generic;
    vrouter_ubuntu_3_13_0_143_generic = self.lib.buildVrouter ubuntuKernelHeaders_3_13_0_143_generic;
    vrouter_ubuntu_4_4_0_101_generic = self.lib.buildVrouter ubuntuKernelHeaders_4_4_0_101_generic;
    vrouter_ubuntu_4_4_0_137_generic = self.lib.buildVrouter ubuntuKernelHeaders_4_4_0_137_generic;
    test = super.test // {
      loadDatabasePrd1 = super.test.loadDatabase.override {
        cassandraDumpPath = prd1CassandraDump + "/tmp/cassandra-dump";
      };
      loadDatabasePrd2 = super.test.loadDatabase.override {
        cassandraDumpPath = prd2CassandraDump + "/cassandra-dump";
      };
      gremlinDumpPrd1 = super.test.gremlinDump.override {
        cassandraDumpPath = prd1CassandraDump + "/tmp/cassandra-dump";
      };
    };
  })
