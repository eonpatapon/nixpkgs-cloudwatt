{ pkgs, python }:

self: super: {

  jsonschema = python.overrideDerivation super.jsonschema (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ super.vcversioner ];
  });

  python-dateutil = python.overrideDerivation super.python-dateutil (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ super.setuptools-scm ];
  });

  requestsexceptions = python.overrideDerivation super.requestsexceptions (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [ super.pbr ];
  });

  openstackclient = with super;
    let
      drv = python.withPackages { inherit python-openstackclient python-octaviaclient; };
      name = "openstackclient-${(builtins.parseDrvName(super.python-openstackclient.name)).version}";
    in drv.interpreter.overrideDerivation (old: {
      inherit name;
      # keep only bin/openstack
      buildCommand = old.buildCommand + ''rm $out/bin/.python* $out/bin/python*'';
    });

}
