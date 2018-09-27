{pkgs}:

version: {
  vrouterModulePostinst = pkgs.writeScript
    "postinst"
    ''
      #!/bin/sh

      set -e

      if [ "$1" = "configure" ]; then
        if [ -e /boot/System.map-${version} ]; then
          depmod -a -F /boot/System.map-${version} ${version} || true
        fi
      fi
    '';
  vrouterModulePostrm = pkgs.writeScript
    "postrm"
    ''
      #!/bin/sh

      set -e

        if [ -e /boot/System.map-${version} ]; then
          depmod -a -F /boot/System.map-${version} ${version} || true
        fi
    '';
  }
