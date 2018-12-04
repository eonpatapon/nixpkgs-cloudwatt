{ callPackage }: {

  hello = callPackage ./hello { };

  contrail = callPackage ./contrail { };

}
