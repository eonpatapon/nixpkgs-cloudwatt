# DO NOT EDIT
# This file has been generated by
# $ ./tools/sources-from-github.sh

{pkgs}:
{
  # Head of branch R3.2-cloudwatt of repository github.com/cloudwatt/contrail-controller at 2018-11-19 14:47:06
  controller = pkgs.fetchFromGitHub {
    name = "controller";
    owner = "cloudwatt";
    repo = "contrail-controller";
    rev = "eded5cada887743fd9bc91c1a3d8bfa0b57dc870";
    sha256 = "15agqfpsbqfjsrbvxfnw72mhxvrmb9ffjqnbv2p28dqii6fx6kz2";
  };
  # Head of branch R3.2-cloudwatt of repository github.com/cloudwatt/contrail-neutron-plugin at 2018-11-19 14:47:21
  neutronPlugin = pkgs.fetchFromGitHub {
    name = "neutronPlugin";
    owner = "cloudwatt";
    repo = "contrail-neutron-plugin";
    rev = "fa09aaf9047949b477104b5aad474884a810212e";
    sha256 = "1z619xmri7ng1jym37aia2q3g1j5dvd1myz4r0l35pnbi2qy82wa";
  };
  # Head of branch R3.2-cloudwatt of repository github.com/cloudwatt/contrail-vrouter at 2018-11-19 14:47:23
  vrouter = pkgs.fetchFromGitHub {
    name = "vrouter";
    owner = "cloudwatt";
    repo = "contrail-vrouter";
    rev = "d03e9789d9e57a434add6cc09df14e64ad45aff8";
    sha256 = "0wxkjfhlxrd7r7q8cc64wqhknals1992qr8ap4w57m09sr0cv2qb";
  };
  # Head of branch R3.2-cloudwatt of repository github.com/cloudwatt/contrail-generateDS at 2018-11-19 14:47:31
  generateds = pkgs.fetchFromGitHub {
    name = "generateds";
    owner = "cloudwatt";
    repo = "contrail-generateDS";
    rev = "42af89aecd8b826e40fd1d4dbcb26d65120fa2f6";
    sha256 = "14sdqq0yzajm9q85z4ghbapg5k708cl2v980zfql0x9ygl7xf69p";
  };
}
