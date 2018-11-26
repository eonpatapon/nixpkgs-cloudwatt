# generated using pypi2nix tool (version: 1.8.1)
# See more at: https://github.com/garbas/pypi2nix
#
# COMMAND:
#   pypi2nix -v -V 2.7 -E which -E libffi -E openssl.dev -e python-openstackclient -e python-octaviaclient -e vcversioner -e setuptools_scm
#

{ pkgs ? import <nixpkgs> {}
}:

let

  inherit (pkgs) makeWrapper;
  inherit (pkgs.stdenv.lib) fix' extends inNixShell;

  pythonPackages =
  import "${toString pkgs.path}/pkgs/top-level/python-packages.nix" {
    inherit pkgs;
    inherit (pkgs) stdenv;
    python = pkgs.python27Full;
    # patching pip so it does not try to remove files when running nix-shell
    overrides =
      self: super: {
        bootstrapped-pip = super.bootstrapped-pip.overrideDerivation (old: {
          patchPhase = old.patchPhase + ''
            sed -i               -e "s|paths_to_remove.remove(auto_confirm)|#paths_to_remove.remove(auto_confirm)|"                -e "s|self.uninstalled = paths_to_remove|#self.uninstalled = paths_to_remove|"                  $out/${pkgs.python35.sitePackages}/pip/req/req_install.py
          '';
        });
      };
  };

  commonBuildInputs = with pkgs; [ which libffi openssl.dev ];
  commonDoCheck = false;

  withPackages = pkgs':
    let
      pkgs = builtins.removeAttrs pkgs' ["__unfix__"];
      interpreter = pythonPackages.buildPythonPackage {
        name = "python27Full-interpreter";
        buildInputs = [ makeWrapper ] ++ (builtins.attrValues pkgs);
        buildCommand = ''
          mkdir -p $out/bin
          ln -s ${pythonPackages.python.interpreter}               $out/bin/${pythonPackages.python.executable}
          for dep in ${builtins.concatStringsSep " "               (builtins.attrValues pkgs)}; do
            if [ -d "$dep/bin" ]; then
              for prog in "$dep/bin/"*; do
                if [ -f $prog ]; then
                  ln -s $prog $out/bin/`basename $prog`
                fi
              done
            fi
          done
          for prog in "$out/bin/"*; do
            wrapProgram "$prog" --prefix PYTHONPATH : "$PYTHONPATH"
          done
          pushd $out/bin
          ln -s ${pythonPackages.python.executable} python
          ln -s ${pythonPackages.python.executable}               python2
          popd
        '';
        passthru.interpreter = pythonPackages.python;
      };
    in {
      __old = pythonPackages;
      inherit interpreter;
      mkDerivation = pythonPackages.buildPythonPackage;
      packages = pkgs;
      overrideDerivation = drv: f:
        pythonPackages.buildPythonPackage (drv.drvAttrs // f drv.drvAttrs //                                            { meta = drv.meta; });
      withPackages = pkgs'':
        withPackages (pkgs // pkgs'');
    };

  python = withPackages {};

  generated = self: {

    "Babel" = python.mkDerivation {
      name = "Babel-2.6.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/be/cc/9c981b249a455fa0c76338966325fc70b7265521bad641bf2932f77712f4/Babel-2.6.0.tar.gz"; sha256 = "8cba50f48c529ca3fa18cf81fa9403be176d374ac4d60738b839122dfaaa3d23"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pytz"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://babel.pocoo.org/";
        license = licenses.bsdOriginal;
        description = "Internationalization utilities";
      };
    };



    "PyYAML" = python.mkDerivation {
      name = "PyYAML-3.13";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9e/a3/1d13970c3f36777c583f136c136f804d70f500168edc1edea6daa7200769/PyYAML-3.13.tar.gz"; sha256 = "3ef3092145e9b70e3ddd2c7ad59bdd0252a94dfe3949721633e41344de00a6bf"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pyyaml.org/wiki/PyYAML";
        license = licenses.mit;
        description = "YAML parser and emitter for Python";
      };
    };



    "appdirs" = python.mkDerivation {
      name = "appdirs-1.4.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/48/69/d87c60746b393309ca30761f8e2b49473d43450b150cb08f3c6df5c11be5/appdirs-1.4.3.tar.gz"; sha256 = "9e5896d1372858f8dd3344faf4e5014d21849c756c8d5701f78f8a103b372d92"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/ActiveState/appdirs";
        license = licenses.mit;
        description = "A small Python module for determining appropriate platform-specific dirs, e.g. a \"user data dir\".";
      };
    };



    "asn1crypto" = python.mkDerivation {
      name = "asn1crypto-0.24.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fc/f1/8db7daa71f414ddabfa056c4ef792e1461ff655c2ae2928a2b675bfed6b4/asn1crypto-0.24.0.tar.gz"; sha256 = "9d5c20441baf0cb60a4ac34cc447c6c189024b6b4c6cd7877034f4965c464e49"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/wbond/asn1crypto";
        license = licenses.mit;
        description = "Fast ASN.1 parser and serializer with definitions for private keys, public keys, certificates, CRL, OCSP, CMS, PKCS#3, PKCS#7, PKCS#8, PKCS#12, PKCS#5, X.509 and TSP";
      };
    };



    "certifi" = python.mkDerivation {
      name = "certifi-2018.10.15";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/41/b6/4f0cefba47656583217acd6cd797bc2db1fede0d53090fdc28ad2c8e0716/certifi-2018.10.15.tar.gz"; sha256 = "6d58c986d22b038c8c0df30d639f23a3e6d172a05c3583e766f4c0b785c0986a"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://certifi.io/";
        license = licenses.mpl20;
        description = "Python package for providing Mozilla's CA Bundle.";
      };
    };



    "cffi" = python.mkDerivation {
      name = "cffi-1.11.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e7/a7/4cd50e57cc6f436f1cc3a7e8fa700ff9b8b4d471620629074913e3735fb2/cffi-1.11.5.tar.gz"; sha256 = "e90f17980e6ab0f3c2f3730e56d1fe9bcba1891eeea58966e89d352492cc74f4"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pycparser"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://cffi.readthedocs.org";
        license = licenses.mit;
        description = "Foreign Function Interface for Python calling C code.";
      };
    };



    "chardet" = python.mkDerivation {
      name = "chardet-3.0.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fc/bb/a5768c230f9ddb03acc9ef3f0d4a3cf93462473795d18e9535498c8f929d/chardet-3.0.4.tar.gz"; sha256 = "84ab92ed1c4d4f16916e05906b6b75a6c0fb5db821cc65e70cbd64a3e2a5eaae"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/chardet/chardet";
        license = licenses.lgpl2;
        description = "Universal encoding detector for Python 2 and 3";
      };
    };



    "cliff" = python.mkDerivation {
      name = "cliff-2.14.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/90/2a/232a69a1f1fe3bdf9a05fd4ec6072c44b63849771d10b6f21a6be701c943/cliff-2.14.0.tar.gz"; sha256 = "21a24dfee9f4e58c397e725bb1568e031d75a8925def92e4d3def2b755f816bc"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PyYAML"
      self."cmd2"
      self."pbr"
      self."prettytable"
      self."pyparsing"
      self."six"
      self."stevedore"
      self."unicodecsv"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/cliff/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Command Line Interface Formulation Framework";
      };
    };



    "cmd2" = python.mkDerivation {
      name = "cmd2-0.8.9";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/21/48/d48fe56f794e9a3feef440e4fb5c80dd4309575e13e132265fc160e82033/cmd2-0.8.9.tar.gz"; sha256 = "145cb677ebd0e3cae546ab81c30f6c25e0b08ba0f1071df854d53707ea792633"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."contextlib2"
      self."enum34"
      self."pyparsing"
      self."pyperclip"
      self."six"
      self."subprocess32"
      self."wcwidth"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/python-cmd2/cmd2";
        license = licenses.mit;
        description = "cmd2 - a tool for building interactive command line applications in Python";
      };
    };



    "contextlib2" = python.mkDerivation {
      name = "contextlib2-0.5.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/6e/db/41233498c210b03ab8b072c8ee49b1cd63b3b0c76f8ea0a0e5d02df06898/contextlib2-0.5.5.tar.gz"; sha256 = "509f9419ee91cdd00ba34443217d5ca51f5a364a404e1dce9e8979cea969ca48"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://contextlib2.readthedocs.org";
        license = licenses.psfl;
        description = "Backports and enhancements for the contextlib module";
      };
    };



    "cryptography" = python.mkDerivation {
      name = "cryptography-2.4.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f3/39/d3904df7c56f8654691c4ae1bdb270c1c9220d6da79bd3b1fbad91afd0e1/cryptography-2.4.2.tar.gz"; sha256 = "05a6052c6a9f17ff78ba78f8e6eb1d777d25db3b763343a1ae89a7a8670386dd"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."asn1crypto"
      self."cffi"
      self."enum34"
      self."idna"
      self."ipaddress"
      self."iso8601"
      self."pytz"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pyca/cryptography";
        license = licenses.bsdOriginal;
        description = "cryptography is a package which provides cryptographic recipes and primitives to Python developers.";
      };
    };



    "debtcollector" = python.mkDerivation {
      name = "debtcollector-1.20.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/56/ea/e8867c97ae9650ecf67edf66ed844c89b3b0a7a54c9ea00b23d889195ec6/debtcollector-1.20.0.tar.gz"; sha256 = "f48639881e0dd492e3576fd714e2a4e422492bb586b9f90affe0f093d7a09ac8"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."funcsigs"
      self."pbr"
      self."six"
      self."wrapt"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/debtcollector/latest";
        license = "License :: OSI Approved :: Apache Software License";
        description = "A collection of Python deprecation patterns and strategies that help you collect your technical debt in a non-destructive manner.";
      };
    };



    "decorator" = python.mkDerivation {
      name = "decorator-4.3.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/6f/24/15a229626c775aae5806312f6bf1e2a73785be3402c0acdec5dbddd8c11e/decorator-4.3.0.tar.gz"; sha256 = "c39efa13fbdeb4506c476c9b3babf6a718da943dab7811c206005a4a956c080c"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/micheles/decorator";
        license = licenses.bsdOriginal;
        description = "Better living through Python with decorators";
      };
    };



    "dogpile.cache" = python.mkDerivation {
      name = "dogpile.cache-0.6.8";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/73/bf/0cbed594e4f0f9360bfb98e7276131bf32e1af1d15e6c11a9dd8bd93a12f/dogpile.cache-0.6.8.tar.gz"; sha256 = "e2fbe5d95e6df3fcfff2b666c69f3c06a4a3f77296142ae2bca523a176f88fa0"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/sqlalchemy/dogpile.cache";
        license = licenses.bsdOriginal;
        description = "A caching front-end based on the Dogpile lock.";
      };
    };



    "enum34" = python.mkDerivation {
      name = "enum34-1.1.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/bf/3e/31d502c25302814a7c2f1d3959d2a3b3f78e509002ba91aea64993936876/enum34-1.1.6.tar.gz"; sha256 = "8ad8c4783bf61ded74527bffb48ed9b54166685e4230386a9ed9b1279e2df5b1"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://bitbucket.org/stoneleaf/enum34";
        license = licenses.bsdOriginal;
        description = "Python 3.4 Enum backported to 3.3, 3.2, 3.1, 2.7, 2.6, 2.5, and 2.4";
      };
    };



    "funcsigs" = python.mkDerivation {
      name = "funcsigs-1.0.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/94/4a/db842e7a0545de1cdb0439bb80e6e42dfe82aaeaadd4072f2263a4fbed23/funcsigs-1.0.2.tar.gz"; sha256 = "a7bb0f2cf3a3fd1ab2732cb49eba4252c2af4240442415b4abce3b87022a8f50"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://funcsigs.readthedocs.org";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Python function signatures from PEP362 for Python 2.6, 2.7 and 3.2+";
      };
    };



    "functools32" = python.mkDerivation {
      name = "functools32-3.2.3.post2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c5/60/6ac26ad05857c601308d8fb9e87fa36d0ebf889423f47c3502ef034365db/functools32-3.2.3-2.tar.gz"; sha256 = "f6253dfbe0538ad2e387bd8fdfd9293c925d63553f5813c4e587745416501e6d"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/MiCHiLU/python-functools32";
        license = "PSF license";
        description = "Backport of the functools module from Python 3.2.3 for use on 2.7 and PyPy.";
      };
    };



    "futures" = python.mkDerivation {
      name = "futures-3.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/1f/9e/7b2ff7e965fc654592269f2906ade1c7d705f1bf25b7d469fa153f7d19eb/futures-3.2.0.tar.gz"; sha256 = "9ec02aa7d674acb8618afb127e27fde7fc68994c0437ad759fa094a574adb265"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/agronholm/pythonfutures";
        license = licenses.psfl;
        description = "Backport of the concurrent.futures package from Python 3";
      };
    };



    "idna" = python.mkDerivation {
      name = "idna-2.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/65/c4/80f97e9c9628f3cac9b98bfca0402ede54e0563b56482e3e6e45c43c4935/idna-2.7.tar.gz"; sha256 = "684a38a6f903c1d71d6d5fac066b58d7768af4de2b832e426ec79c30daa94a16"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/kjd/idna";
        license = licenses.bsdOriginal;
        description = "Internationalized Domain Names in Applications (IDNA)";
      };
    };



    "ipaddress" = python.mkDerivation {
      name = "ipaddress-1.0.22";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/97/8d/77b8cedcfbf93676148518036c6b1ce7f8e14bf07e95d7fd4ddcb8cc052f/ipaddress-1.0.22.tar.gz"; sha256 = "b146c751ea45cad6188dd6cf2d9b757f6f4f8d6ffb96a023e6f2e26eea02a72c"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/phihag/ipaddress";
        license = licenses.psfl;
        description = "IPv4/IPv6 manipulation library";
      };
    };



    "iso8601" = python.mkDerivation {
      name = "iso8601-0.1.12";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/45/13/3db24895497345fb44c4248c08b16da34a9eb02643cea2754b21b5ed08b0/iso8601-0.1.12.tar.gz"; sha256 = "49c4b20e1f38aa5cf109ddcd39647ac419f928512c869dc01d5c7098eddede82"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://bitbucket.org/micktwomey/pyiso8601";
        license = licenses.mit;
        description = "Simple module to parse ISO 8601 dates";
      };
    };



    "jmespath" = python.mkDerivation {
      name = "jmespath-0.9.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e5/21/795b7549397735e911b032f255cff5fb0de58f96da794274660bca4f58ef/jmespath-0.9.3.tar.gz"; sha256 = "6a81d4c9aa62caf061cb517b4d9ad1dd300374cd4706997aff9cd6aedd61fc64"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/jmespath/jmespath.py";
        license = licenses.mit;
        description = "JSON Matching Expressions";
      };
    };



    "jsonpatch" = python.mkDerivation {
      name = "jsonpatch-1.23";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9a/7d/bcf203d81939420e1aaf7478a3efce1efb8ccb4d047a33cb85d7f96d775e/jsonpatch-1.23.tar.gz"; sha256 = "49f29cab70e9068db3b1dc6b656cbe2ee4edf7dfe9bf5a0055f17a4b6804a4b9"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."jsonpointer"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/stefankoegl/python-json-patch";
        license = licenses.bsdOriginal;
        description = "Apply JSON-Patches (RFC 6902) ";
      };
    };



    "jsonpointer" = python.mkDerivation {
      name = "jsonpointer-2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/52/e7/246d9ef2366d430f0ce7bdc494ea2df8b49d7a2a41ba51f5655f68cfe85f/jsonpointer-2.0.tar.gz"; sha256 = "c192ba86648e05fdae4f08a17ec25180a9aef5008d973407b581798a83975362"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/stefankoegl/python-json-pointer";
        license = licenses.bsdOriginal;
        description = "Identify specific nodes in a JSON document (RFC 6901) ";
      };
    };



    "jsonschema" = python.mkDerivation {
      name = "jsonschema-2.6.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/58/b9/171dbb07e18c6346090a37f03c7e74410a1a56123f847efed59af260a298/jsonschema-2.6.0.tar.gz"; sha256 = "6ff5f3180870836cae40f06fa10419f557208175f13ad7bc26caa77beb1f6e02"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."functools32"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/Julian/jsonschema";
        license = licenses.mit;
        description = "An implementation of JSON Schema validation for Python";
      };
    };



    "keystoneauth1" = python.mkDerivation {
      name = "keystoneauth1-3.11.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/3b/c1/ef5904e9d1961b45c2a2cc0bfd9ac3aaeabfab8580683009fb9a94b65b78/keystoneauth1-3.11.1.tar.gz"; sha256 = "c1adb59c82c989b7c6293231da0fd46d30adfe2b7d9e35f327e3bfe7a0f99656"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PyYAML"
      self."iso8601"
      self."os-service-types"
      self."oslo.config"
      self."oslo.utils"
      self."pbr"
      self."requests"
      self."six"
      self."stevedore"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/keystoneauth/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Authentication Library for OpenStack Identity";
      };
    };



    "monotonic" = python.mkDerivation {
      name = "monotonic-1.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/19/c1/27f722aaaaf98786a1b338b78cf60960d9fe4849825b071f4e300da29589/monotonic-1.5.tar.gz"; sha256 = "23953d55076df038541e648a53676fb24980f7a1be290cdda21300b3bc21dfb0"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/atdt/monotonic";
        license = "License :: OSI Approved :: Apache Software License";
        description = "An implementation of time.monotonic() for Python 2 & < 3.3";
      };
    };



    "msgpack" = python.mkDerivation {
      name = "msgpack-0.5.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f3/b6/9affbea179c3c03a0eb53515d9ce404809a122f76bee8fc8c6ec9497f51f/msgpack-0.5.6.tar.gz"; sha256 = "0ee8c8c85aa651be3aa0cd005b5931769eaa658c948ce79428766f1bd46ae2c3"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://msgpack.org/";
        license = licenses.asl20;
        description = "MessagePack (de)serializer.";
      };
    };



    "munch" = python.mkDerivation {
      name = "munch-2.3.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/68/f4/260ec98ea840757a0da09e0ed8135333d59b8dfebe9752a365b04857660a/munch-2.3.2.tar.gz"; sha256 = "6ae3d26b837feacf732fb8aa5b842130da1daf221f5af9f9d4b2a0a6414b0d51"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/Infinidat/munch";
        license = licenses.mit;
        description = "A dot-accessible dictionary (a la JavaScript objects).";
      };
    };



    "netaddr" = python.mkDerivation {
      name = "netaddr-0.7.19";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/0c/13/7cbb180b52201c07c796243eeff4c256b053656da5cfe3916c3f5b57b3a0/netaddr-0.7.19.tar.gz"; sha256 = "38aeec7cdd035081d3a4c306394b19d677623bf76fa0913f6695127c7753aefd"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/drkjam/netaddr/";
        license = licenses.bsdOriginal;
        description = "A network address manipulation library for Python";
      };
    };



    "netifaces" = python.mkDerivation {
      name = "netifaces-0.10.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/81/39/4e9a026265ba944ddf1fea176dbb29e0fe50c43717ba4fcf3646d099fe38/netifaces-0.10.7.tar.gz"; sha256 = "bd590fcb75421537d4149825e1e63cca225fd47dad861710c46bd1cb329d8cbd"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/al45tair/netifaces";
        license = licenses.mit;
        description = "Portable network interface information.";
      };
    };



    "openstacksdk" = python.mkDerivation {
      name = "openstacksdk-0.19.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9f/7d/06813c1256abcd83df5ba87c4a547bce741baa54f5a948659359137c2aca/openstacksdk-0.19.0.tar.gz"; sha256 = "822356c4dfff43273a75ed60825c934fc40fb9a8132dcfcdd8a3beb81a183e61"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PyYAML"
      self."appdirs"
      self."cryptography"
      self."decorator"
      self."dogpile.cache"
      self."futures"
      self."ipaddress"
      self."iso8601"
      self."jmespath"
      self."jsonpatch"
      self."keystoneauth1"
      self."munch"
      self."netifaces"
      self."os-service-types"
      self."pbr"
      self."requestsexceptions"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://developer.openstack.org/sdks/python/openstacksdk/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "An SDK for building applications to work with OpenStack";
      };
    };



    "os-client-config" = python.mkDerivation {
      name = "os-client-config-1.31.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/80/bb/e7d5c7ae06ccbab1c9a3f8b9ea2a99d16981b66b5f2cad21f1b94a0eca0e/os-client-config-1.31.2.tar.gz"; sha256 = "4e9de6be30d2314bfb40a723ee01fa630e9b6764e0e5680e7418acf1566d0e12"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."openstacksdk"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/os-client-config/latest";
        license = "License :: OSI Approved :: Apache Software License";
        description = "OpenStack Client Configuation Library";
      };
    };



    "os-service-types" = python.mkDerivation {
      name = "os-service-types-1.3.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a2/bc/c8bc9cce8ec064558ae9b8ab2dbea9d5bdfbaf5c50f637a19cb120410b10/os-service-types-1.3.0.tar.gz"; sha256 = "5790117948d1673319a2dcf4c545c2059a1a933705e8ded586add88200ac9d95"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pbr"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.openstack.org/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Python library for consuming OpenStack sevice-types-authority data";
      };
    };



    "osc-lib" = python.mkDerivation {
      name = "osc-lib-1.11.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/8d/a8/b63a53baed828a3e46ff2d1ee5cb63f794e9e071f05e99229642edfc46a5/osc-lib-1.11.1.tar.gz"; sha256 = "4b118f72757b84c8375e8af47bb59151337fbc50305a6c5b5307ad7442422af4"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."cliff"
      self."keystoneauth1"
      self."openstacksdk"
      self."oslo.i18n"
      self."oslo.utils"
      self."pbr"
      self."simplejson"
      self."six"
      self."stevedore"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/osc-lib/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "OpenStackClient Library";
      };
    };



    "oslo.config" = python.mkDerivation {
      name = "oslo.config-6.7.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b9/a0/402bd835656b6261df354daa16a814eaccf0221a512ceffec49504125783/oslo.config-6.7.0.tar.gz"; sha256 = "5d57ae2efc4f61b6ae11d0074baa93e9ab5e13be77f899d24d280ce66b92208c"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PyYAML"
      self."debtcollector"
      self."enum34"
      self."netaddr"
      self."oslo.i18n"
      self."requests"
      self."rfc3986"
      self."six"
      self."stevedore"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/oslo.config/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Configuration API";
      };
    };



    "oslo.context" = python.mkDerivation {
      name = "oslo.context-2.21.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/79/d7/fe6f06ab54056091c4a4a203ed54d26851726a0f7145b4bb68c9ebcb1a47/oslo.context-2.21.0.tar.gz"; sha256 = "163d3d24a90545c2a56a587499027106b5a76d7c9854d2a906e19dd794d6b313"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."debtcollector"
      self."pbr"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/oslo.context/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Context library";
      };
    };



    "oslo.i18n" = python.mkDerivation {
      name = "oslo.i18n-3.22.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d7/ec/70a4b44b07a64dd34a1b37eaba4c19bad16e37670f1f874e88c780fdd6c6/oslo.i18n-3.22.1.tar.gz"; sha256 = "dccc5d4f3c0976917a47de709f4e49db1b3ce790bdadc852e38238f9cdb94b0d"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."pbr"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/oslo.i18n/latest";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo i18n library";
      };
    };



    "oslo.log" = python.mkDerivation {
      name = "oslo.log-3.41.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/cc/88/bde1fa9d85df5d6b2105d2f0cad21cb2a90de171365e2fd3266c25930ee6/oslo.log-3.41.0.tar.gz"; sha256 = "7b345cd5b74e37d39476e1441f81b966a8f00fb8be3eec9200b2520f9fead3b3"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."debtcollector"
      self."monotonic"
      self."oslo.config"
      self."oslo.context"
      self."oslo.i18n"
      self."oslo.serialization"
      self."oslo.utils"
      self."pbr"
      self."pyinotify"
      self."python-dateutil"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/oslo.log/latest";
        license = "License :: OSI Approved :: Apache Software License";
        description = "oslo.log library";
      };
    };



    "oslo.serialization" = python.mkDerivation {
      name = "oslo.serialization-2.28.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ec/ef/e08efaec5c3bc155f6e6cfc1703bb6e6f95171332436a24a6ee6d15ba01c/oslo.serialization-2.28.1.tar.gz"; sha256 = "fd1febd9abe2042052846a39b7b8ad0f878cc5365d4484d241f0b0711601b8ee"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."msgpack"
      self."oslo.utils"
      self."pbr"
      self."pytz"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://docs.openstack.org/developer/oslo.serialization/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Serialization library";
      };
    };



    "oslo.utils" = python.mkDerivation {
      name = "oslo.utils-3.37.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/5e/af/236047dfea57407df332e49e1b68d023c3e1408ab24e4d9d8c7a2a8be519/oslo.utils-3.37.1.tar.gz"; sha256 = "374bc8f1be9969cc15b7ac70afb5bd2ec58bc1220f5196e6d53ab83c9f0b1888"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."debtcollector"
      self."funcsigs"
      self."iso8601"
      self."monotonic"
      self."netaddr"
      self."netifaces"
      self."oslo.i18n"
      self."pbr"
      self."pyparsing"
      self."pytz"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/oslo.utils/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Utility library";
      };
    };



    "pbr" = python.mkDerivation {
      name = "pbr-5.1.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/33/07/6e68a96ff240a0e7bb1f6e21093532386a98a82d56512e1e3da6d125f7aa/pbr-5.1.1.tar.gz"; sha256 = "f59d71442f9ece3dffc17bc36575768e1ee9967756e6b6535f0ee1f0054c3d68"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/pbr/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Python Build Reasonableness";
      };
    };



    "prettytable" = python.mkDerivation {
      name = "prettytable-0.7.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ef/30/4b0746848746ed5941f052479e7c23d2b56d174b82f4fd34a25e389831f5/prettytable-0.7.2.tar.bz2"; sha256 = "853c116513625c738dc3ce1aee148b5b5757a86727e67eff6502c7ca59d43c36"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://code.google.com/p/prettytable";
        license = licenses.bsdOriginal;
        description = "A simple Python library for easily displaying tabular data in a visually appealing ASCII table format";
      };
    };



    "pyOpenSSL" = python.mkDerivation {
      name = "pyOpenSSL-18.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/9b/7c/ee600b2a9304d260d96044ab5c5e57aa489755b92bbeb4c0803f9504f480/pyOpenSSL-18.0.0.tar.gz"; sha256 = "6488f1423b00f73b7ad5167885312bb0ce410d3312eb212393795b53c8caa580"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."cryptography"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://pyopenssl.org/";
        license = licenses.asl20;
        description = "Python wrapper module around the OpenSSL library";
      };
    };



    "pycparser" = python.mkDerivation {
      name = "pycparser-2.19";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/68/9e/49196946aee219aead1290e00d1e7fdeab8567783e83e1b9ab5585e6206a/pycparser-2.19.tar.gz"; sha256 = "a988718abfad80b6b157acce7bf130a30876d27603738ac39f140993246b25b3"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/eliben/pycparser";
        license = licenses.bsdOriginal;
        description = "C parser in Python";
      };
    };



    "pyinotify" = python.mkDerivation {
      name = "pyinotify-0.9.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e3/c0/fd5b18dde17c1249658521f69598f3252f11d9d7a980c5be8619970646e1/pyinotify-0.9.6.tar.gz"; sha256 = "9c998a5d7606ca835065cdabc013ae6c66eb9ea76a00a1e3bc6e0cfe2b4f71f4"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/seb-m/pyinotify";
        license = licenses.mit;
        description = "Linux filesystem events monitoring";
      };
    };



    "pyparsing" = python.mkDerivation {
      name = "pyparsing-2.3.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d0/09/3e6a5eeb6e04467b737d55f8bba15247ac0876f98fae659e58cd744430c6/pyparsing-2.3.0.tar.gz"; sha256 = "f353aab21fd474459d97b709e527b5571314ee5f067441dc9f88e33eecd96592"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pyparsing/pyparsing/";
        license = licenses.mit;
        description = "Python parsing module";
      };
    };



    "pyperclip" = python.mkDerivation {
      name = "pyperclip-1.7.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/2d/0f/4eda562dffd085945d57c2d9a5da745cfb5228c02bc90f2c74bbac746243/pyperclip-1.7.0.tar.gz"; sha256 = "979325468ccf682104d5dcaf753f869868100631301d3e72f47babdea5700d1c"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/asweigart/pyperclip";
        license = licenses.bsdOriginal;
        description = "A cross-platform clipboard module for Python. (Only handles plain text for now.)";
      };
    };



    "python-cinderclient" = python.mkDerivation {
      name = "python-cinderclient-4.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/44/54/ba8a5f7aefcbc2e13e5ecdd38c37d86c7bf17f73138d74461425b6fa6f30/python-cinderclient-4.1.0.tar.gz"; sha256 = "8fb1fd1481860615730595e77ff6008a73fa516aed530825bd7cda0f221351d4"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."keystoneauth1"
      self."oslo.i18n"
      self."oslo.utils"
      self."pbr"
      self."prettytable"
      self."simplejson"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/python-cinderclient/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "OpenStack Block Storage API Client Library";
      };
    };



    "python-dateutil" = python.mkDerivation {
      name = "python-dateutil-2.7.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/0e/01/68747933e8d12263d41ce08119620d9a7e5eb72c876a3442257f74490da0/python-dateutil-2.7.5.tar.gz"; sha256 = "88f9287c0174266bb0d8cedd395cfba9c58e87e5ad86b2ce58859bc11be3cf02"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://dateutil.readthedocs.io";
        license = licenses.bsdOriginal;
        description = "Extensions to the standard Python datetime module";
      };
    };



    "python-glanceclient" = python.mkDerivation {
      name = "python-glanceclient-2.14.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e6/3a/0637e9ba650cccecf94defb89b5cc400919c15473f60e1d7b1bbe7389fe5/python-glanceclient-2.14.0.tar.gz"; sha256 = "f5ae499e426c49716cee0fc4440092b8fac96bdbd94c77618959241707558936"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."keystoneauth1"
      self."oslo.i18n"
      self."oslo.utils"
      self."pbr"
      self."prettytable"
      self."pyOpenSSL"
      self."requests"
      self."six"
      self."warlock"
      self."wrapt"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/python-glanceclient/latest/";
        license = licenses.asl20;
        description = "OpenStack Image API Client Library";
      };
    };



    "python-keystoneclient" = python.mkDerivation {
      name = "python-keystoneclient-3.18.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/4a/d7/7ee2efca36b975da19b5e2ae76a6dec38a38f8fb5cc92145aa9c58903312/python-keystoneclient-3.18.0.tar.gz"; sha256 = "2825f3bf20f8b4f6b43bdf393462de3d4b116135b02bb4059960c7e9caf638d3"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."debtcollector"
      self."keystoneauth1"
      self."oslo.config"
      self."oslo.i18n"
      self."oslo.serialization"
      self."oslo.utils"
      self."pbr"
      self."requests"
      self."six"
      self."stevedore"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/python-keystoneclient/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Client Library for OpenStack Identity";
      };
    };



    "python-neutronclient" = python.mkDerivation {
      name = "python-neutronclient-6.11.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/47/af/b2f1f26df007078e23a651a1af4fb2100d075ccb24fefe70028c9c0f23c7/python-neutronclient-6.11.0.tar.gz"; sha256 = "eacc4626cd1f59390977e89aad9a3a7600dc45e916020e0b0946912b7c174bc4"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."cliff"
      self."debtcollector"
      self."iso8601"
      self."keystoneauth1"
      self."netaddr"
      self."os-client-config"
      self."osc-lib"
      self."oslo.i18n"
      self."oslo.log"
      self."oslo.serialization"
      self."oslo.utils"
      self."pbr"
      self."python-keystoneclient"
      self."requests"
      self."simplejson"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/python-neutronclient/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "CLI and Client Library for OpenStack Networking";
      };
    };



    "python-novaclient" = python.mkDerivation {
      name = "python-novaclient-11.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/08/99/e3eafae3326e3f0259474794b8325422f72b7bf31dce7e6fea96fa20dd5e/python-novaclient-11.1.0.tar.gz"; sha256 = "446ebdc69522e8a469de4fbb2798b4e4796c3766625cda3f5aad57ff9ae8cb5b"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."iso8601"
      self."keystoneauth1"
      self."oslo.i18n"
      self."oslo.serialization"
      self."oslo.utils"
      self."pbr"
      self."prettytable"
      self."simplejson"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/python-novaclient/latest";
        license = licenses.asl20;
        description = "Client library for OpenStack Compute API";
      };
    };



    "python-octaviaclient" = python.mkDerivation {
      name = "python-octaviaclient-1.6.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d3/99/db61b856a47f4164d670f2a77a42cff66d34a77257656e583b00fc94b938/python-octaviaclient-1.6.0.tar.gz"; sha256 = "295efa38b5f44819e10094d9f5451954af41a64485a3df538cf15d26c6371414"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."PyYAML"
      self."appdirs"
      self."cliff"
      self."cmd2"
      self."debtcollector"
      self."funcsigs"
      self."iso8601"
      self."keystoneauth1"
      self."monotonic"
      self."netaddr"
      self."netifaces"
      self."os-client-config"
      self."osc-lib"
      self."oslo.i18n"
      self."oslo.serialization"
      self."oslo.utils"
      self."pbr"
      self."prettytable"
      self."pyparsing"
      self."python-neutronclient"
      self."python-openstackclient"
      self."pytz"
      self."requests"
      self."requestsexceptions"
      self."simplejson"
      self."six"
      self."stevedore"
      self."unicodecsv"
      self."wrapt"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/python-octaviaclient/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Octavia client for OpenStack Load Balancing";
      };
    };



    "python-openstackclient" = python.mkDerivation {
      name = "python-openstackclient-3.17.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/04/a8/7c6147df12e1f588ed31cc357794ce71d06c68187c8f173df7fe68e7b0b4/python-openstackclient-3.17.0.tar.gz"; sha256 = "225ddc0126010b19f4d765a394f88605ca1d95f49c4d4f07b68051d21d0b7ccd"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."cliff"
      self."keystoneauth1"
      self."openstacksdk"
      self."osc-lib"
      self."oslo.i18n"
      self."oslo.utils"
      self."pbr"
      self."python-cinderclient"
      self."python-glanceclient"
      self."python-keystoneclient"
      self."python-novaclient"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/python-openstackclient/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "OpenStack Command-line Client";
      };
    };



    "pytz" = python.mkDerivation {
      name = "pytz-2018.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/cd/71/ae99fc3df1b1c5267d37ef2c51b7d79c44ba8a5e37b48e3ca93b4d74d98b/pytz-2018.7.tar.gz"; sha256 = "31cb35c89bd7d333cd32c5f278fca91b523b0834369e757f4c5641ea252236ca"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pythonhosted.org/pytz";
        license = licenses.mit;
        description = "World timezone definitions, modern and historical";
      };
    };



    "requests" = python.mkDerivation {
      name = "requests-2.20.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/40/35/298c36d839547b50822985a2cf0611b3b978a5ab7a5af5562b8ebe3e1369/requests-2.20.1.tar.gz"; sha256 = "ea881206e59f41dbd0bd445437d792e43906703fff75ca8ff43ccdb11f33f263"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."certifi"
      self."chardet"
      self."cryptography"
      self."idna"
      self."pyOpenSSL"
      self."urllib3"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://python-requests.org";
        license = licenses.asl20;
        description = "Python HTTP for Humans.";
      };
    };



    "requestsexceptions" = python.mkDerivation {
      name = "requestsexceptions-1.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/82/ed/61b9652d3256503c99b0b8f145d9c8aa24c514caff6efc229989505937c1/requestsexceptions-1.4.0.tar.gz"; sha256 = "b095cbc77618f066d459a02b137b020c37da9f46d9b057704019c9f77dba3065"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.openstack.org/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Import exceptions from potentially bundled packages in requests.";
      };
    };



    "rfc3986" = python.mkDerivation {
      name = "rfc3986-1.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/4b/f6/8f0a24e50454494b0736fe02e6617e7436f2b30148b8f062462177e2ca2d/rfc3986-1.1.0.tar.gz"; sha256 = "8458571c4c57e1cf23593ad860bb601b6a604df6217f829c2bc70dc4b5af941b"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://rfc3986.readthedocs.io";
        license = licenses.asl20;
        description = "Validating URI References per RFC 3986";
      };
    };



    "setuptools-scm" = python.mkDerivation {
      name = "setuptools-scm-3.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/09/b4/d148a70543b42ff3d81d57381f33104f32b91f970ad7873f463e75bf7453/setuptools_scm-3.1.0.tar.gz"; sha256 = "1191f2a136b5e86f7ca8ab00a97ef7aef997131f1f6d4971be69a1ef387d8b40"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pypa/setuptools_scm/";
        license = licenses.mit;
        description = "the blessed package to manage your versions by scm tags";
      };
    };



    "simplejson" = python.mkDerivation {
      name = "simplejson-3.16.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/e3/24/c35fb1c1c315fc0fffe61ea00d3f88e85469004713dab488dee4f35b0aff/simplejson-3.16.0.tar.gz"; sha256 = "b1f329139ba647a9548aa05fb95d046b4a677643070dc2afc05fa2e975d09ca5"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/simplejson/simplejson";
        license = licenses.mit;
        description = "Simple, fast, extensible JSON encoder/decoder for Python";
      };
    };



    "six" = python.mkDerivation {
      name = "six-1.11.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/16/d8/bc6316cf98419719bd59c91742194c111b6f2e85abac88e496adefaf7afe/six-1.11.0.tar.gz"; sha256 = "70e8a77beed4562e7f14fe23a786b54f6296e34344c23bc42f07b15018ff98e9"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pypi.python.org/pypi/six/";
        license = licenses.mit;
        description = "Python 2 and 3 compatibility utilities";
      };
    };



    "stevedore" = python.mkDerivation {
      name = "stevedore-1.30.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fd/e3/5bc7226601d6405b588efc9c9f22e3cb0ada577eb957cdcd0ae9093ab6d8/stevedore-1.30.0.tar.gz"; sha256 = "b92bc7add1a53fb76c634a178978d113330aaf2006f9498d9e2414b31fbfc104"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pbr"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://docs.openstack.org/stevedore/latest/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Manage dynamic plugins for Python applications";
      };
    };



    "subprocess32" = python.mkDerivation {
      name = "subprocess32-3.5.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/be/2b/beeba583e9877e64db10b52a96915afc0feabf7144dcbf2a0d0ea68bf73d/subprocess32-3.5.3.tar.gz"; sha256 = "6bc82992316eef3ccff319b5033809801c0c3372709c5f6985299c88ac7225c3"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/google/python-subprocess32";
        license = licenses.psfl;
        description = "A backport of the subprocess module from Python 3 for use on 2.x.";
      };
    };



    "unicodecsv" = python.mkDerivation {
      name = "unicodecsv-0.14.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/6f/a4/691ab63b17505a26096608cc309960b5a6bdf39e4ba1a793d5f9b1a53270/unicodecsv-0.14.1.tar.gz"; sha256 = "018c08037d48649a0412063ff4eda26eaa81eff1546dbffa51fa5293276ff7fc"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/jdunck/python-unicodecsv";
        license = licenses.bsdOriginal;
        description = "Python2's stdlib csv module is nice, but it doesn't support unicode. This module is a drop-in replacement which *does*.";
      };
    };



    "urllib3" = python.mkDerivation {
      name = "urllib3-1.24.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b1/53/37d82ab391393565f2f831b8eedbffd57db5a718216f82f1a8b4d381a1c1/urllib3-1.24.1.tar.gz"; sha256 = "de9529817c93f27c8ccbfead6985011db27bd0ddfcdb2d86f3f663385c6a9c22"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."certifi"
      self."cryptography"
      self."idna"
      self."ipaddress"
      self."pyOpenSSL"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://urllib3.readthedocs.io/";
        license = licenses.mit;
        description = "HTTP library with thread-safe connection pooling, file post, and more.";
      };
    };



    "vcversioner" = python.mkDerivation {
      name = "vcversioner-2.16.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c5/cc/33162c0a7b28a4d8c83da07bc2b12cee58c120b4a9e8bba31c41c8d35a16/vcversioner-2.16.0.0.tar.gz"; sha256 = "dae60c17a479781f44a4010701833f1829140b1eeccd258762a74974aa06e19b"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/habnabit/vcversioner";
        license = licenses.isc;
        description = "Use version control tags to discover version numbers";
      };
    };



    "warlock" = python.mkDerivation {
      name = "warlock-1.3.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/2d/40/9f01a5e1574dab946598793351d59c86f58209d182d229aaa545abb98894/warlock-1.3.0.tar.gz"; sha256 = "d7403f728fce67ee2f22f3d7fa09c9de0bc95c3e7bcf6005b9c1962b77976a06"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."jsonpatch"
      self."jsonschema"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/bcwaldon/warlock";
        license = "";
        description = "Python object model built on JSON schema and JSON patch.";
      };
    };



    "wcwidth" = python.mkDerivation {
      name = "wcwidth-0.1.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/55/11/e4a2bb08bb450fdbd42cc709dd40de4ed2c472cf0ccb9e64af22279c5495/wcwidth-0.1.7.tar.gz"; sha256 = "3df37372226d6e63e1b1e1eda15c594bca98a22d33a23832a90998faa96bc65e"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/jquast/wcwidth";
        license = licenses.mit;
        description = "Measures number of Terminal column cells of wide-character codes";
      };
    };



    "wrapt" = python.mkDerivation {
      name = "wrapt-1.10.11";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a0/47/66897906448185fcb77fc3c2b1bc20ed0ecca81a0f2f88eda3fc5a34fc3d/wrapt-1.10.11.tar.gz"; sha256 = "d4d560d479f2c21e1b5443bbd15fe7ec4b37fe7e53d335d3b9b0a7b1226fe3c6"; };
      doCheck = commonDoCheck;
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/GrahamDumpleton/wrapt";
        license = licenses.bsdOriginal;
        description = "Module for decorators, wrappers and monkey patching.";
      };
    };

  };
  localOverridesFile = ./requirements_override.nix;
  overrides = import localOverridesFile { inherit pkgs python; };
  commonOverrides = [

  ];
  allOverrides =
    (if (builtins.pathExists localOverridesFile)
     then [overrides] else [] ) ++ commonOverrides;

in python.withPackages
   (fix' (pkgs.lib.fold
            extends
            generated
            allOverrides
         )
   )