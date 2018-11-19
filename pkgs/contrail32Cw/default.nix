{ callPackage, contrail32, ubuntuKernelHeaders }:

with ubuntuKernelHeaders;

contrail32.overrideScope' (self: super: {
  contrailSources = super.contrailSources // (callPackage ./sources.nix { });
  vrouter_ubuntu_3_13_0_83_generic = self.lib.buildVrouter ubuntuKernelHeaders_3_13_0_83_generic;
  vrouter_ubuntu_3_13_0_112_generic = self.lib.buildVrouter ubuntuKernelHeaders_3_13_0_112_generic;
  vrouter_ubuntu_3_13_0_125_generic = self.lib.buildVrouter ubuntuKernelHeaders_3_13_0_125_generic;
  vrouter_ubuntu_3_13_0_141_generic = self.lib.buildVrouter ubuntuKernelHeaders_3_13_0_141_generic;
  vrouter_ubuntu_3_13_0_143_generic = self.lib.buildVrouter ubuntuKernelHeaders_3_13_0_143_generic;
  vrouter_ubuntu_4_4_0_101_generic = self.lib.buildVrouter ubuntuKernelHeaders_4_4_0_101_generic;
  vrouter_ubuntu_4_4_0_137_generic = self.lib.buildVrouter ubuntuKernelHeaders_4_4_0_137_generic;
})
