{pkgs}:

version: {
  vrouterModulePostinst = pkgs.writeScript
    "contrail-vrouter-module.postinst"
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
    "contrail-vrouter-module.postrm"
    ''
      #!/bin/sh

      set -e

        if [ -e /boot/System.map-${version} ]; then
          depmod -a -F /boot/System.map-${version} ${version} || true
        fi
    '';
  }
