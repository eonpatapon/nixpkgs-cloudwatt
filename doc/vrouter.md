# Contrail vrouter build

## How to manually compile a vrouter kernel module

    $ nix-shell -A contrail32Cw.vrouter_ubuntu_3_13_0_83_generic
    [nix-shell] $ unpackPhase
    [nix-shell] $ cd contrail-workspace
    [nix-shell] $ scons --kernel-dir=$kernelSrc vrouter/vrouter.ko

## How to build the vrouter for a new kernel version

First, add fetch expressions in `pkgs/ubuntu-kernel-headers/default.nix` to
get both Ubuntu kernel sources and CONFIG.

    ubuntuKernelHeaders_3_13_0_83_generic = ubuntuKernelHeaders "3.13.0-83-generic" [
       (pkgs.fetchurl {
         url = http://fr.archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-3.13.0-83-generic_3.13.0-83.127_amd64.deb;
         sha256 = "f8b5431798c315b7c08be0fb5614c844c38a07c0b6656debc9cc8833400bdd98";
       })
       (pkgs.fetchurl {
         url = http://fr.archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-3.13.0-83_3.13.0-83.127_all.deb;
         sha256 = "7281be1ab2dc3b5627ef8577402fd3e17e0445880d22463e494027f8e904e8fa";
       })
    ];

URLs can be found by browsing packages.ubuntu.com. For instance https://packages.ubuntu.com/trusty-updates/linux-headers-3.13.0-83-generic.

Then, add an attribute in `debian-packages/default.nix` that builds the vrouter
kernel module by using these new sources.

    Vrouter_ubuntu_3_13_0_83_generic = vrouterUbuntu deps.ubuntuKernelHeaders_3_13_0_83_generic;
