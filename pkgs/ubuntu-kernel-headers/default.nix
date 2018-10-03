{ stdenv, fetchurl, patchelf, dpkg, rsync }:

let
  # Packages urls can be foung by browsing https://packages.ubuntu.com/trusty-updates/linux-headers-3.13.0-83-generic
  # We need the fetch two packages to have both the kernel headers and the kernel configuration.
  ubuntuKernelHeaders = version: srcs: stdenv.mkDerivation rec {
    inherit version srcs;
    pname = "ubuntu-kernel-headers";
    name = "${pname}-${version}";
    phases = [ "unpackPhase" "installPhase" ];
    buildInputs = [ dpkg ];
    unpackCmd = "dpkg-deb --extract $curSrc tmp/";
    installPhase = ''
      mkdir -p $out
      ${rsync}/bin/rsync -rl * $out/

      # We patch these scripts since they have been compiled for ubuntu
      for i in recordmcount basic/fixdep mod/modpost; do
        ${patchelf}/bin/patchelf --set-interpreter ${stdenv.glibc}/lib/ld-linux-x86-64.so.2 $out/usr/src/linux-headers-${version}/scripts/$i
        ${patchelf}/bin/patchelf --set-rpath ${stdenv.glibc}/lib $out//usr/src/linux-headers-${version}/scripts/$i
      done

      ln -sfT $out/usr/src/linux-headers-${version} $out/lib/modules/${version}/build
    '';
  };
in
{
  ubuntuKernelHeaders_3_13_0_83_generic = ubuntuKernelHeaders "3.13.0-83-generic" [
    (fetchurl {
      url = http://fr.archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-3.13.0-83-generic_3.13.0-83.127_amd64.deb;
      sha256 = "f8b5431798c315b7c08be0fb5614c844c38a07c0b6656debc9cc8833400bdd98";
    })
    (fetchurl {
      url = http://fr.archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-3.13.0-83_3.13.0-83.127_all.deb;
      sha256 = "7281be1ab2dc3b5627ef8577402fd3e17e0445880d22463e494027f8e904e8fa";
    })
  ];

  ubuntuKernelHeaders_3_13_0_112_generic = ubuntuKernelHeaders "3.13.0-112-generic" [
    (fetchurl {
      url = http://fr.archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-3.13.0-112-generic_3.13.0-112.159_amd64.deb;
      sha256 = "0kjj6zkr8yh79haj7xqdqndwq2rhcvs53wzkgfa666q939dh4dr0";
    })
    (fetchurl {
      url = http://fr.archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-3.13.0-112_3.13.0-112.159_all.deb;
      sha256 = "1irx346ifqbirz4pfncpz1spynhy3hmy1y3sfmva339vx6a224y9";
    })
  ];

  ubuntuKernelHeaders_3_13_0_125_generic = ubuntuKernelHeaders "3.13.0-125-generic" [
    (fetchurl {
      url = http://fr.archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-3.13.0-125-generic_3.13.0-125.174_amd64.deb;
      sha256 = "0s231qkf5bjdnaj103xxv1wwspy4vlgbsgzk93254ixqvsjh5hbr";
    })
    (fetchurl {
      url = http://fr.archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-3.13.0-125_3.13.0-125.174_all.deb;
      sha256 = "1hbb6z1i5xjx68nssxm90jr6h142n8cphbi8z688cz05zrnzlk60";
    })
  ];

  ubuntuKernelHeaders_3_13_0_141_generic = ubuntuKernelHeaders "3.13.0-141-generic" [
    (fetchurl {
      url = http://fr.archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-3.13.0-141-generic_3.13.0-141.190_amd64.deb;
      sha256 = "77534d51d1b98f683ef207a0f93a8c9ef349c1a1db9bc672950b7c22693d2fcd";
    })
    (fetchurl {
      url = http://fr.archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-3.13.0-141_3.13.0-141.190_all.deb;
      sha256 = "0q3k5p0iihnnkc2vgcrkib7ix1v66ci2bpw1dq0f28sj3mxnbv41";
    })
  ];

  ubuntuKernelHeaders_3_13_0_143_generic = ubuntuKernelHeaders "3.13.0-143-generic" [
    (fetchurl {
      url = http://fr.archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-3.13.0-143-generic_3.13.0-143.192_amd64.deb;
      sha256 = "de5afb956c5518e834d24b4aaf66f7ef7480c2204712aef61f2672ea832d8774";
    })
    (fetchurl {
      url = http://fr.archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-3.13.0-143_3.13.0-143.192_all.deb;
      sha256 = "c36477034bf0bf112698393e8ed7879d9afff20775c99c6d2dfa39fad21bd61c";
    })
  ];

  ubuntuKernelHeaders_4_4_0_101_generic = ubuntuKernelHeaders "4.4.0-101-generic" [
    (fetchurl {
      url = http://fr.archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-4.4.0-101-generic_4.4.0-101.124_amd64.deb;
      sha256 = "0sm03g37ndp5hyxkk8sszy5jkwcp1css2nlpyw4jsw57kwncrmx6";
    })
    (fetchurl {
      url = http://fr.archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-4.4.0-101_4.4.0-101.124_all.deb;
      sha256 = "1zxnwm1a4y9lfszl8idh0kcirwyy78ml4s54kb1hxfm88kllhbcc";
    })
  ];

  ubuntuKernelHeaders_4_4_0_137_generic = ubuntuKernelHeaders "4.4.0-137-generic" [
    (fetchurl {
      url = http://fr.archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-4.4.0-137-generic_4.4.0-137.163_amd64.deb;
      sha256 = "02c7m10a967kd2l84grzksyqdfzkvac0y5m3bd51cpw4wir6rz8s";
    })
    (fetchurl {
      url = http://fr.archive.ubuntu.com/ubuntu/pool/main/l/linux/linux-headers-4.4.0-137_4.4.0-137.163_all.deb;
      sha256 = "18qv1bkwciqynj5v7w1l46w0adypcafbhqwkfggkgbp629xm3y2s";
    })
  ];
}
