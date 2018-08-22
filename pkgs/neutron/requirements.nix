# generated using pypi2nix tool (version: 1.8.1)
# See more at: https://github.com/garbas/pypi2nix
#
# COMMAND:
#   pypi2nix -V 2.7 -r requirements-all.nix -E libffi -E openssl.dev
#

{ pkgs ? import <nixpkgs> {},
  overrides ? ({ pkgs, python }: self: super: {})
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
            if [ -e $out/${pkgs.python27Full.sitePackages}/pip/req/req_install.py ]; then
              sed -i \
                -e "s|paths_to_remove.remove(auto_confirm)|#paths_to_remove.remove(auto_confirm)|"  \
                -e "s|self.uninstalled = paths_to_remove|#self.uninstalled = paths_to_remove|"  \
                $out/${pkgs.python27Full.sitePackages}/pip/req/req_install.py
            fi
          '';
        });
      };
  };

  commonBuildInputs = with pkgs; [ libffi openssl.dev ];
  commonDoCheck = false;

  withPackages = pkgs':
    let
      pkgs = builtins.removeAttrs pkgs' ["__unfix__"];
      interpreterWithPackages = selectPkgsFn: pythonPackages.buildPythonPackage {
        name = "python27Full-interpreter";
        buildInputs = [ makeWrapper ] ++ (selectPkgsFn pkgs);
        buildCommand = ''
          mkdir -p $out/bin
          ln -s ${pythonPackages.python.interpreter} \
              $out/bin/${pythonPackages.python.executable}
          for dep in ${builtins.concatStringsSep " "
              (selectPkgsFn pkgs)}; do
            if [ -d "$dep/bin" ]; then
              for prog in "$dep/bin/"*; do
                if [ -x "$prog" ] && [ -f "$prog" ]; then
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
          ln -s ${pythonPackages.python.executable} \
              python2
          popd
        '';
        passthru.interpreter = pythonPackages.python;
      };

      interpreter = interpreterWithPackages builtins.attrValues;
    in {
      __old = pythonPackages;
      inherit interpreter;
      inherit interpreterWithPackages;
      mkDerivation = pythonPackages.buildPythonPackage;
      packages = pkgs;
      overrideDerivation = drv: f:
        pythonPackages.buildPythonPackage (
          drv.drvAttrs // f drv.drvAttrs // { meta = drv.meta; }
        );
      withPackages = pkgs'':
        withPackages (pkgs // pkgs'');
    };

  python = withPackages {};

  generated = self: {
    "Babel" = python.mkDerivation {
      name = "Babel-2.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/08/00/278d52a7ba3c5f9709d50bd123d0cc4f66497a9bab1b6b2bc18d3fcced09/Babel-2.2.0.tar.gz"; sha256 = "d8cb4c0e78148aee89560f9fe21587aa57739c975bb89ff66b1e842cc697428f"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
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

    "Jinja2" = python.mkDerivation {
      name = "Jinja2-2.8";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f2/2f/0b98b06a345a761bec91a079ccae392d282690c2d8272e708f4d10829e22/Jinja2-2.8.tar.gz"; sha256 = "bc1ff2ff88dbfacefde4ddde471d1417d3b304e8df103a7a9437d47269201bf4"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."MarkupSafe"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://jinja.pocoo.org/";
        license = licenses.bsdOriginal;
        description = "A small but fast and easy to use stand-alone template engine written in pure python.";
      };
    };

    "Mako" = python.mkDerivation {
      name = "Mako-1.0.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/36/17/8f76e7acf8679ad70b23e61710152785d32de71a783a873a655f855d0d46/Mako-1.0.3.tar.gz"; sha256 = "7644bc0ee35965d2e146dde31827b8982ed70a58281085fac42869a09764d38c"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."MarkupSafe"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.makotemplates.org/";
        license = licenses.mit;
        description = "A super-fast templating language that borrows the  best ideas from the existing templating languages.";
      };
    };

    "MarkupSafe" = python.mkDerivation {
      name = "MarkupSafe-0.23";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c0/41/bae1254e0396c0cc8cf1751cb7d9afc90a602353695af5952530482c963f/MarkupSafe-0.23.tar.gz"; sha256 = "a4ec1aff59b95a14b45eb2e23761a0179e98319da5a7eb76b56ea8cdc7b871c3"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/mitsuhiko/markupsafe";
        license = licenses.bsdOriginal;
        description = "Implements a XML/HTML/XHTML Markup safe string for Python";
      };
    };

    "Paste" = python.mkDerivation {
      name = "Paste-2.0.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d5/8d/0f8ac40687b97ff3e07ebd1369be20bdb3f93864d2dc3c2ff542edb4ce50/Paste-2.0.2.tar.gz"; sha256 = "adac3ac893a2dac6b8ffd49901377dd6819e05be3436b374d698641071daba99"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pythonpaste.org";
        license = licenses.mit;
        description = "Tools for using a Web Server Gateway Interface stack";
      };
    };

    "PasteDeploy" = python.mkDerivation {
      name = "PasteDeploy-1.5.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/0f/90/8e20cdae206c543ea10793cbf4136eb9a8b3f417e04e40a29d72d9922cbd/PasteDeploy-1.5.2.tar.gz"; sha256 = "d5858f89a255e6294e63ed46b73613c56e3b9a2d82a42f1df4d06c8421a9e3cb"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Paste"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pythonpaste.org/deploy/";
        license = licenses.mit;
        description = "Load, configure, and compose WSGI applications and servers";
      };
    };

    "PyMySQL" = python.mkDerivation {
      name = "PyMySQL-0.7.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/97/17/a8cbe4281fe212a8bbf9027323cfcd8e0a7f2eed4675ebcdf87adbd15a7c/PyMySQL-0.7.2.tar.gz"; sha256 = "bd7acb4990dbf097fae3417641f93e25c690e01ed25c3ed32ea638d6c3ac04ba"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/PyMySQL/PyMySQL/";
        license = licenses.mit;
        description = "Pure Python MySQL Driver";
      };
    };

    "PyYAML" = python.mkDerivation {
      name = "PyYAML-3.11";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/75/5e/b84feba55e20f8da46ead76f14a3943c8cb722d40360702b2365b91dec00/PyYAML-3.11.tar.gz"; sha256 = "c36c938a872e5ff494938b33b14aaa156cb439ec67548fcab3535bb78b0846e8"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pyyaml.org/wiki/PyYAML";
        license = licenses.mit;
        description = "YAML parser and emitter for Python";
      };
    };

    "Routes" = python.mkDerivation {
      name = "Routes-2.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/db/0a/ff1ad39029f07fca303be80cf2487860acb133c5fea34a606a694ebf0224/Routes-2.2.tar.gz"; sha256 = "9fa78373d63e36c3d8af6e33cfcad743f70c012c7ad6f2c3bf89ad973b9ab514"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."repoze.lru"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://routes.readthedocs.org/";
        license = licenses.mit;
        description = "Routing Recognition and Generation Tools";
      };
    };

    "SQLAlchemy" = python.mkDerivation {
      name = "SQLAlchemy-1.0.12";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/5c/52/9b48cd58eac58cae2a27923ff34c783f390b95413ff65669a86e98f80829/SQLAlchemy-1.0.12.tar.gz"; sha256 = "6679e20eae780b67ba136a4a76f83bb264debaac2542beefe02069d0206518d1"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.sqlalchemy.org";
        license = licenses.mit;
        description = "Database Abstraction Library";
      };
    };

    "Tempita" = python.mkDerivation {
      name = "Tempita-0.5.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/56/c8/8ed6eee83dbddf7b0fc64dd5d4454bc05e6ccaafff47991f73f2894d9ff4/Tempita-0.5.2.tar.gz"; sha256 = "cacecf0baa674d356641f1d406b8bff1d756d739c46b869a54de515d08e6fc9c"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pythonpaste.org/tempita/";
        license = licenses.mit;
        description = "A very small text templating language";
      };
    };

    "WebOb" = python.mkDerivation {
      name = "WebOb-1.5.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/3c/63/3c3c183cf9ba0e30fe5d72d12c511af3bc5493b48e00f4f8ae3689a9d777/WebOb-1.5.1.tar.gz"; sha256 = "d8a9a153577f74b275dfd441ee2de4910eb2c1228d94186285684327e3877009"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://webob.org/";
        license = licenses.mit;
        description = "WSGI request and response object";
      };
    };

    "WebTest" = python.mkDerivation {
      name = "WebTest-2.0.20";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/4a/9d/db5a6d351404b15a1afbbf348d5f12d204bec57a8f871d6ee4bfe024ada7/WebTest-2.0.20.tar.gz"; sha256 = "bb137b96ce300eb4e43377804ed45be87674af7d414c4de46bba4d251bc4602f"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PasteDeploy"
      self."WebOb"
      self."beautifulsoup4"
      self."six"
      self."waitress"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://webtest.pythonpaste.org/";
        license = licenses.mit;
        description = "Helper to test WSGI applications";
      };
    };

    "alembic" = python.mkDerivation {
      name = "alembic-0.8.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ca/7e/299b4499b5c75e5a38c5845145ad24755bebfb8eec07a2e1c366b7181eeb/alembic-0.8.4.tar.gz"; sha256 = "8507fc12ccc99321da2fa117dde4b5d8664ff5ef017df7ce5e7e5051901a624a"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Mako"
      self."SQLAlchemy"
      self."python-editor"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://bitbucket.org/zzzeek/alembic";
        license = licenses.mit;
        description = "A database migration tool for SQLAlchemy.";
      };
    };

    "amqp" = python.mkDerivation {
      name = "amqp-1.4.9";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/cc/a4/f265c6f9a7eb1dd45d36d9ab775520e07ff575b11ad21156f9866da047b2/amqp-1.4.9.tar.gz"; sha256 = "2dea4d16d073c902c3b89d9b96620fb6729ac0f7a923bbc777cb4ad827c0c61a"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/celery/py-amqp";
        license = licenses.lgpl2;
        description = "Low-level AMQP client for Python (fork of amqplib)";
      };
    };

    "anyjson" = python.mkDerivation {
      name = "anyjson-0.3.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c3/4d/d4089e1a3dd25b46bebdb55a992b0797cff657b4477bc32ce28038fdecbc/anyjson-0.3.3.tar.gz"; sha256 = "37812d863c9ad3e35c0734c42e0bf0320ce8c3bed82cd20ad54cb34d158157ba"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://bitbucket.org/runeh/anyjson/";
        license = licenses.bsdOriginal;
        description = "Wraps the best available JSON implementation available in a common interface";
      };
    };

    "appdirs" = python.mkDerivation {
      name = "appdirs-1.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/bd/66/0a7f48a0f3fb1d3a4072bceb5bbd78b1a6de4d801fb7135578e7c7b1f563/appdirs-1.4.0.tar.gz"; sha256 = "8fc245efb4387a4e3e0ac8ebcc704582df7d72ff6a42a53f5600bbb18fdaadc5"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/ActiveState/appdirs";
        license = licenses.mit;
        description = "A small Python module for determining appropriate \" +         \"platform-specific dirs, e.g. a \"user data dir\".";
      };
    };

    "beautifulsoup4" = python.mkDerivation {
      name = "beautifulsoup4-4.4.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/26/79/ef9a8bcbec5abc4c618a80737b44b56f1cb393b40238574078c5002b97ce/beautifulsoup4-4.4.1.tar.gz"; sha256 = "87d4013d0625d4789a4f56b8d79a04d5ce6db1152bb65f1d39744f7709a366b4"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.crummy.com/software/BeautifulSoup/bs4/";
        license = licenses.mit;
        description = "Screen-scraping library";
      };
    };

    "cachetools" = python.mkDerivation {
      name = "cachetools-1.1.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fe/7d/07e6f9f15fbe16638b1ddee34b745a0fbae5de4af39732de4610bc6b0d20/cachetools-1.1.5.tar.gz"; sha256 = "9810dd6afaec9e9eaae5ec33f2aa7117214a7a3f8427e70ab23939fe4d1bf279"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/tkem/cachetools";
        license = licenses.mit;
        description = "Extensible memoizing collections and decorators";
      };
    };

    "cffi" = python.mkDerivation {
      name = "cffi-1.5.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c7/bb/2e1ba0ef25477929b44040800a880f02b42efb757e06a9d8899591582ba4/cffi-1.5.2.tar.gz"; sha256 = "da9bde99872e46f7bb5cff40a9b1cc08406765efafb583c704de108b6cb821dd"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
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

    "cliff" = python.mkDerivation {
      name = "cliff-2.0.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/23/80/bd8e87608c4536a729e0b791982711b61918818d8658ae3cb7c898f77c00/cliff-2.0.0.tar.gz"; sha256 = "6e219dc3ed80a23e3dc5c88b741f3997b8450581c1d2572bde14b2dfa556d782"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
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
        homepage = "https://launchpad.net/python-cliff";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Command Line Interface Formulation Framework";
      };
    };

    "cmd2" = python.mkDerivation {
      name = "cmd2-0.6.8";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/20/65/6e5518c6bbfe9fe33be1364a6e83d372f837019dfdb31b207b2db3d84865/cmd2-0.6.8.tar.gz"; sha256 = "ac780d8c31fc107bf6b4edcbcea711de4ff776d59d89bb167f8819d2d83764a8"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pyparsing"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://packages.python.org/cmd2/";
        license = licenses.mit;
        description = "Extra features for standard library's cmd module";
      };
    };

    "contextlib2" = python.mkDerivation {
      name = "contextlib2-0.5.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/1e/82/8fa4e44f849237b13b6631b6a975692c7fd73ad16c0632cccf3df07d06bd/contextlib2-0.5.1.tar.gz"; sha256 = "227c79e126e8a8904a81d162750581ed3d49af2395a3100be7067b7296d33d45"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://contextlib2.readthedocs.org";
        license = licenses.psfl;
        description = "Backports and enhancements for the contextlib module";
      };
    };

    "cryptography" = python.mkDerivation {
      name = "cryptography-1.2.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/8b/7d/9df253f059c8d9a9389f06df5d6301b0725a44dbf055a1f7aff8e455746a/cryptography-1.2.3.tar.gz"; sha256 = "8eb11c77dd8e73f48df6b2f7a7e16173fe0fe8fdfe266232832e88477e08454e"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."cffi"
      self."enum34"
      self."idna"
      self."ipaddress"
      self."iso8601"
      self."pyasn1"
      self."pyasn1-modules"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pyca/cryptography";
        license = licenses.bsdOriginal;
        description = "cryptography is a package which provides cryptographic recipes and primitives to Python developers.";
      };
    };

    "debtcollector" = python.mkDerivation {
      name = "debtcollector-1.3.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/93/03/0c29c185855b823880fedac0e914892554e210c0427de3e6bab0f7e25468/debtcollector-1.3.0.tar.gz"; sha256 = "9a65cf09239eab75b961ef609b3176ed2487bedcfa0a465331661824e1c8db8f"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."funcsigs"
      self."pbr"
      self."six"
      self."wrapt"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.openstack.org/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "A collection of Python deprecation patterns and strategies that help you collect your technical debt in a non-destructive manner.";
      };
    };

    "decorator" = python.mkDerivation {
      name = "decorator-4.0.9";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/68/04/621a0f896544814ce6c6a0e6bc01d19fc41d245d4515a2e4cf9e07a45a12/decorator-4.0.9.tar.gz"; sha256 = "90022e83316363788a55352fe39cfbed357aa3a71d90e5f2803a35471de4bba8"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/micheles/decorator";
        license = licenses.bsdOriginal;
        description = "Better living through Python with decorators";
      };
    };

    "enum34" = python.mkDerivation {
      name = "enum34-1.1.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/6f/e9/08fd439384b7e3d613e75a6c8236b8e64d90c47d23413493b38d4229a9a5/enum34-1.1.2.tar.gz"; sha256 = "2475d7fcddf5951e92ff546972758802de5260bf409319a9f1934e6bbc8b1dc7"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://pypi.python.org/pypi/enum34";
        license = licenses.bsdOriginal;
        description = "Python 3.4 Enum backported to 3.3, 3.2, 3.1, 2.7, 2.6, 2.5, and 2.4";
      };
    };

    "eventlet" = python.mkDerivation {
      name = "eventlet-0.18.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/32/4b/6c1630dafe7216c01029c4d84a25fab165b4b967e2c1c9f09947e4788f70/eventlet-0.18.4.tar.gz"; sha256 = "74ef11d67ee5e85e009b0fced733c907620bca1ab8e6b0489d9f247405ab2685"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."greenlet"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://eventlet.net";
        license = licenses.mit;
        description = "Highly concurrent networking library";
      };
    };

    "fasteners" = python.mkDerivation {
      name = "fasteners-0.14.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f4/6f/41b835c9bf69b03615630f8a6f6d45dafbec95eb4e2bb816638f043552b2/fasteners-0.14.1.tar.gz"; sha256 = "427c76773fe036ddfa41e57d89086ea03111bbac57c55fc55f3006d027107e18"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."monotonic"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/harlowja/fasteners";
        license = "License :: OSI Approved :: Apache Software License";
        description = "A python package that provides useful locks.";
      };
    };

    "funcsigs" = python.mkDerivation {
      name = "funcsigs-0.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/87/5e/44bc85c41e5b33b6bf1fcb2f6ccbc4ee74337af079438d2a28c5c45137e1/funcsigs-0.4.tar.gz"; sha256 = "d83ce6df0b0ea6618700fe1db353526391a8a3ada1b7aba52fed7a61da772033"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
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
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/MiCHiLU/python-functools32";
        license = "PSF license";
        description = "Backport of the functools module from Python 3.2.3 for use on 2.7 and PyPy.";
      };
    };

    "futures" = python.mkDerivation {
      name = "futures-3.0.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/55/db/97c1ca37edab586a1ae03d6892b6633d8eaa23b23ac40c7e5bbc55423c78/futures-3.0.5.tar.gz"; sha256 = "0542525145d5afc984c88f914a0c85c77527f65946617edb5274f72406f981df"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/agronholm/pythonfutures";
        license = licenses.bsdOriginal;
        description = "Backport of the concurrent.futures package from Python 3.2";
      };
    };

    "futurist" = python.mkDerivation {
      name = "futurist-0.13.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/63/13/386aa79bc3ca96da3aff8e86f4cd0e207102461eb738f4ee3bce3b323ae3/futurist-0.13.0.tar.gz"; sha256 = "2d51e23607f42bcd84fcf666b91d9a41c131943d85f7a252e599cdea6518ab1c"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."contextlib2"
      self."futures"
      self."monotonic"
      self."pbr"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.openstack.org/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Useful additions to futures, from the future.";
      };
    };

    "greenlet" = python.mkDerivation {
      name = "greenlet-0.4.9";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ba/19/7ae57aa8b66f918859206532b1afd7f876582e3c87434ff33261da1cf50c/greenlet-0.4.9.tar.gz"; sha256 = "79f9b8bbbb1c599c66aed5e643e8b53bae697cae46e0acfc4ee461df48a90012"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/python-greenlet/greenlet";
        license = licenses.mit;
        description = "Lightweight in-process concurrent programming";
      };
    };

    "httplib2" = python.mkDerivation {
      name = "httplib2-0.9.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ff/a9/5751cdf17a70ea89f6dde23ceb1705bfb638fd8cee00f845308bf8d26397/httplib2-0.9.2.tar.gz"; sha256 = "c3aba1c9539711551f4d83e857b316b5134a1c4ddce98a875b7027be7dd6d988"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/jcgregorio/httplib2";
        license = licenses.mit;
        description = "A comprehensive HTTP client library.";
      };
    };

    "idna" = python.mkDerivation {
      name = "idna-2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/69/27/5f76009f13c6dda4ed5016cbfebf68773f21374f9792db02821c05326a75/idna-2.0.tar.gz"; sha256 = "16199aad938b290f5be1057c0e1efc6546229391c23cea61ca940c115f7d3d3b"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/kjd/idna";
        license = licenses.bsdOriginal;
        description = "Internationalized Domain Names in Applications (IDNA)";
      };
    };

    "ipaddress" = python.mkDerivation {
      name = "ipaddress-1.0.16";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/cd/c5/bd44885274379121507870d4abfe7ba908326cf7bfd50a48d9d6ae091c0d/ipaddress-1.0.16.tar.gz"; sha256 = "5a3182b322a706525c46282ca6f064d27a02cffbd449f9f47416f1dc96aa71b0"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/phihag/ipaddress";
        license = licenses.psfl;
        description = "IPv4/IPv6 manipulation library";
      };
    };

    "iso8601" = python.mkDerivation {
      name = "iso8601-0.1.11";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c0/75/c9209ee4d1b5975eb8c2cba4428bde6b61bd55664a98290dd015cdb18e98/iso8601-0.1.11.tar.gz"; sha256 = "e8fb52f78880ae063336c94eb5b87b181e6a0cc33a6c008511bac9a6e980ef30"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://bitbucket.org/micktwomey/pyiso8601";
        license = licenses.mit;
        description = "Simple module to parse ISO 8601 dates";
      };
    };

    "jsonschema" = python.mkDerivation {
      name = "jsonschema-2.5.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/58/0d/c816f5ea5adaf1293a1d81d32e4cdfdaf8496973aa5049786d7fdb14e7e7/jsonschema-2.5.1.tar.gz"; sha256 = "36673ac378feed3daa5956276a829699056523d7961027911f064b52255ead41"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."functools32"
      self."repoze.lru"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/Julian/jsonschema";
        license = licenses.mit;
        description = "An implementation of JSON Schema validation for Python";
      };
    };

    "keystoneauth1" = python.mkDerivation {
      name = "keystoneauth1-2.4.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/fe/1b/a6347b80d0055d125cb6c86a6d9b44c77184a7ba8433f6f0616a07e76e99/keystoneauth1-2.4.3.tar.gz"; sha256 = "41c2f32fb6b26f9e99ee6e4fe6318760fc3701fd55ddd8e78ba5dbf83b88d33b"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."iso8601"
      self."oslo.config"
      self."oslo.utils"
      self."pbr"
      self."positional"
      self."requests"
      self."six"
      self."stevedore"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.openstack.org/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Authentication Library for OpenStack Identity";
      };
    };

    "keystonemiddleware" = python.mkDerivation {
      name = "keystonemiddleware-4.4.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a6/1a/741245e4f4c6736f032b8aee596c884e6682fa3ab7c178f06a34e2391b70/keystonemiddleware-4.4.1.tar.gz"; sha256 = "dff35f0e4acb77f34c9c880bd4f456bbe26a1c4701815d82e8c27ff74a5dfb52"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."WebOb"
      self."keystoneauth1"
      self."oslo.config"
      self."oslo.context"
      self."oslo.i18n"
      self."oslo.serialization"
      self."oslo.utils"
      self."pbr"
      self."positional"
      self."pycadf"
      self."python-keystoneclient"
      self."requests"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://launchpad.net/keystonemiddleware";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Middleware for OpenStack Identity";
      };
    };

    "kombu" = python.mkDerivation {
      name = "kombu-3.0.34";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/bb/41/563d20ed360dd11636b8fb29a6809ffd83bac1fef61158e4bf08c29b316d/kombu-3.0.34.tar.gz"; sha256 = "8878ff19b09d86b2689682a4a3eb163d70115ef4ebd974966079a0edd80075da"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."amqp"
      self."anyjson"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://kombu.readthedocs.org";
        license = licenses.bsdOriginal;
        description = "Messaging library for Python";
      };
    };

    "logutils" = python.mkDerivation {
      name = "logutils-0.3.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/bc/53/c4abf7b947383a7a56f282ad68328322cd08a93e2528151038ad6c17d012/logutils-0.3.3.tar.gz"; sha256 = "4042b8e57cbe3b01552b3c84191595ae6c36f1ab5aef7e3a6ce5c2f15c297c9c"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://code.google.com/p/logutils/";
        license = licenses.bsdOriginal;
        description = "Logging utilities";
      };
    };

    "monotonic" = python.mkDerivation {
      name = "monotonic-0.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/71/be/df50d24c036ff1f316f835db207c1934250f1b82b53d4ea1a14068052293/monotonic-0.6.tar.gz"; sha256 = "2bc780a16024427cb4bfbfff77ed328484cf6937a787cc50055b83b13b653e74"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/atdt/monotonic";
        license = "License :: OSI Approved :: Apache Software License";
        description = "An implementation of time.monotonic() for Python 2 & < 3.3";
      };
    };

    "msgpack-python" = python.mkDerivation {
      name = "msgpack-python-0.4.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/a3/fb/bcf568236ade99903ef3e3e186e2d9252adbf000b378de596058fb9df847/msgpack-python-0.4.7.tar.gz"; sha256 = "5e001229a54180a02dcdd59db23c9978351af55b1290c27bc549e381f43acd6b"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://msgpack.org/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "MessagePack (de)serializer.";
      };
    };

    "netaddr" = python.mkDerivation {
      name = "netaddr-0.7.18";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/7c/ec/104f193e985e0aa813ffb4ba5da78d6ae3200165bf583d522ac2dc40aab2/netaddr-0.7.18.tar.gz"; sha256 = "a1f5c9fcf75ac2579b9995c843dade33009543c04f218ff7c007b3c81695bd19"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/drkjam/netaddr/";
        license = licenses.bsdOriginal;
        description = "A network address manipulation library for Python";
      };
    };

    "netifaces" = python.mkDerivation {
      name = "netifaces-0.10.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/18/fa/dd13d4910aea339c0bb87d2b3838d8fd923c11869b1f6e741dbd0ff3bc00/netifaces-0.10.4.tar.gz"; sha256 = "9656a169cb83da34d732b0eb72b39373d48774aee009a3d1272b7ea2ce109cde"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://bitbucket.org/al45tair/netifaces";
        license = licenses.mit;
        description = "Portable network interface information.";
      };
    };

    "neutron-lib" = python.mkDerivation {
      name = "neutron-lib-0.0.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/8e/ae/9b516d86c65f09e549f61752c3c05fa7019fcb3d4cbf854895a61424eab4/neutron-lib-0.0.2.tar.gz"; sha256 = "2040a08937bece401a49fb4a867ccf5a910a8267edc26947ab0c523b4903ce7d"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."debtcollector"
      self."oslo.config"
      self."oslo.db"
      self."oslo.i18n"
      self."oslo.log"
      self."oslo.messaging"
      self."oslo.service"
      self."oslo.utils"
      self."pbr"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.openstack.org/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Neutron shared routines and utilities";
      };
    };

    "os-client-config" = python.mkDerivation {
      name = "os-client-config-1.16.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c7/f3/fbf6f1a481c20bcb65f291e5b5113bb7061f7ef45c88bd354325b7a9185e/os-client-config-1.16.0.tar.gz"; sha256 = "d25dfb1b74552339442875bedb1e9328de66c5644b8dff0b31cc140f1d6ac9fd"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PyYAML"
      self."appdirs"
      self."keystoneauth1"
      self."requestsexceptions"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.openstack.org/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "OpenStack Client Configuation Library";
      };
    };

    "oslo.concurrency" = python.mkDerivation {
      name = "oslo.concurrency-3.7.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/16/d0/3137f73a2e854f137fea5da0b527960fcb8db75f45af27ee10be7835f464/oslo.concurrency-3.7.1.tar.gz"; sha256 = "254a42d9f0a5f21e9d56e5fd5ca7c3e355ba22d06ea47f6eb094155242ccc0f6"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."enum34"
      self."fasteners"
      self."iso8601"
      self."oslo.config"
      self."oslo.i18n"
      self."oslo.utils"
      self."pbr"
      self."retrying"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://launchpad.net/oslo";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Concurrency library";
      };
    };

    "oslo.config" = python.mkDerivation {
      name = "oslo.config-3.9.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/76/11/0b9f876b8543b61db75b35ca214e6123c6a832045e413e20429697f3a2e9/oslo.config-3.9.0.tar.gz"; sha256 = "ec7bdf4a3d85f90cf07d2fa03a20783558ad0f490d71bd8faf50bf4ee2923df1"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."debtcollector"
      self."netaddr"
      self."six"
      self."stevedore"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://wiki.openstack.org/wiki/Oslo#oslo.config";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Configuration API";
      };
    };

    "oslo.context" = python.mkDerivation {
      name = "oslo.context-2.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/89/55/3f53b3cd2988f0d01f8124471267b90d136f4844f4ac6152f5a3a7ca27ac/oslo.context-2.2.0.tar.gz"; sha256 = "8c9fbbf56d3f37cf00a039cac3455cffeb6588f61537e36a36ce9447c4be72ec"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."pbr"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://launchpad.net/oslo";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Context library";
      };
    };

    "oslo.db" = python.mkDerivation {
      name = "oslo.db-4.7.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b2/d3/1b3179a080fcb81726e4f36fccb8cbaf7845ff2f330acf7de67a7e8572dc/oslo.db-4.7.1.tar.gz"; sha256 = "a39e091e4d06c757dd6249f121e2ae1babef595f451f7ff56110c0be718d0d8c"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."PyMySQL"
      self."SQLAlchemy"
      self."alembic"
      self."eventlet"
      self."oslo.config"
      self."oslo.context"
      self."oslo.i18n"
      self."oslo.utils"
      self."pbr"
      self."six"
      self."sqlalchemy-migrate"
      self."stevedore"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://wiki.openstack.org/wiki/Oslo#oslo.db";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Database library";
      };
    };

    "oslo.i18n" = python.mkDerivation {
      name = "oslo.i18n-3.5.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ab/b7/947e1b78dcc3b2fdc57ac57e9a98c6603d3c03acd721c0460fb826e41fad/oslo.i18n-3.5.0.tar.gz"; sha256 = "5fff5f6ceabed9d09b18d83e049864c29eff038efbbe67e03fe68c49cc189f10"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."pbr"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://wiki.openstack.org/wiki/Oslo#oslo.i18n";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo i18n library";
      };
    };

    "oslo.log" = python.mkDerivation {
      name = "oslo.log-3.3.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c8/fc/ac67e1ee4a284346316f260d91dbe1ca7687c689d0c1490e7f24efbbe70d/oslo.log-3.3.0.tar.gz"; sha256 = "b3414b6f3b05f50571d8973543227f0d6445c297ba762262adfc28b704f8efd9"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."debtcollector"
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
        homepage = "http://www.openstack.org";
        license = "License :: OSI Approved :: Apache Software License";
        description = "oslo.log library";
      };
    };

    "oslo.messaging" = python.mkDerivation {
      name = "oslo.messaging-4.6.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ac/80/aabd1dc790964e74e645bb6b353eec9e839d69249704e179cd010ebc58fa/oslo.messaging-4.6.1.tar.gz"; sha256 = "be0499c3c2bf22f7ab3934bd2c331af6eea47f8c6508774d209a8028e9582421"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."PyYAML"
      self."WebOb"
      self."amqp"
      self."cachetools"
      self."debtcollector"
      self."eventlet"
      self."futures"
      self."futurist"
      self."greenlet"
      self."kombu"
      self."oslo.config"
      self."oslo.context"
      self."oslo.i18n"
      self."oslo.log"
      self."oslo.middleware"
      self."oslo.serialization"
      self."oslo.service"
      self."oslo.utils"
      self."pbr"
      self."pika"
      self."pika-pool"
      self."retrying"
      self."six"
      self."stevedore"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://wiki.openstack.org/wiki/Oslo#oslo.messaging";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Messaging API";
      };
    };

    "oslo.middleware" = python.mkDerivation {
      name = "oslo.middleware-3.8.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/0e/bf/079e130f0ec6014f9d81b394be01440e90cb797871d1f93132d9be1de0a1/oslo.middleware-3.8.0.tar.gz"; sha256 = "2d985b238182cf70c1adbe1a041eb96eacde3106751fe2c7f1cd81d57a4dbda2"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."Jinja2"
      self."WebOb"
      self."debtcollector"
      self."oslo.config"
      self."oslo.context"
      self."oslo.i18n"
      self."oslo.utils"
      self."pbr"
      self."six"
      self."stevedore"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://wiki.openstack.org/wiki/Oslo#oslo.middleware";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Middleware library";
      };
    };

    "oslo.policy" = python.mkDerivation {
      name = "oslo.policy-1.6.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/59/ec/f059fb0d7a79066cfb74cae1caacf1917c1eda92993ea1ebfaf6f47f3721/oslo.policy-1.6.0.tar.gz"; sha256 = "24d5ecdf4e10f33a9fb2e8784876f73276637d8663c33f594e8efc99e179016a"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."oslo.config"
      self."oslo.i18n"
      self."oslo.serialization"
      self."oslo.utils"
      self."requests"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://launchpad.net/oslo.policy";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Policy library";
      };
    };

    "oslo.reports" = python.mkDerivation {
      name = "oslo.reports-1.7.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/66/85/752b4607acf144cdf0905d79097d90c293f9507c79d9e8ecedbdbd042b06/oslo.reports-1.7.0.tar.gz"; sha256 = "288e9a3b699fcefcb9ae8d848a965e5c6918729b4200ae0e799b077a8e8ecafa"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."Jinja2"
      self."oslo.i18n"
      self."oslo.serialization"
      self."oslo.utils"
      self."pbr"
      self."psutil"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://launchpad.net/oslo";
        license = "License :: OSI Approved :: Apache Software License";
        description = "oslo.reports library";
      };
    };

    "oslo.rootwrap" = python.mkDerivation {
      name = "oslo.rootwrap-4.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/1a/78/3dec49ae3f622424b06f594ca111a6096b5d1804d0062ee8a28a39e75d83/oslo.rootwrap-4.1.0.tar.gz"; sha256 = "083b6255228982484fc483db845a49e07f474cfc12ba1ba70490f56880027989"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://launchpad.net/oslo";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Rootwrap";
      };
    };

    "oslo.serialization" = python.mkDerivation {
      name = "oslo.serialization-2.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/0e/5e/b6b65b089694ded68322a78cb97df7fead4da315c1480862b9ca2c796566/oslo.serialization-2.4.0.tar.gz"; sha256 = "9b95fc07310fd6df8cab064f89fd15327b259dec17a2e2b9a07b9ca4d96be0c6"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."msgpack-python"
      self."oslo.utils"
      self."pbr"
      self."pytz"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://launchpad.net/oslo";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Serialization library";
      };
    };

    "oslo.service" = python.mkDerivation {
      name = "oslo.service-1.8.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/34/ae/956d3a9b04b31a669121d2cb85e1e394c0784c0c1c3e31a68c9e34a75fcc/oslo.service-1.8.0.tar.gz"; sha256 = "cfd519945adb986f3e9e9bb01bebe1a0875ba38b1463a7deb6a7cba5a4e02d4d"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."Paste"
      self."PasteDeploy"
      self."Routes"
      self."WebOb"
      self."eventlet"
      self."greenlet"
      self."monotonic"
      self."oslo.concurrency"
      self."oslo.config"
      self."oslo.i18n"
      self."oslo.log"
      self."oslo.utils"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://wiki.openstack.org/wiki/Oslo#oslo.service";
        license = "License :: OSI Approved :: Apache Software License";
        description = "oslo.service library";
      };
    };

    "oslo.utils" = python.mkDerivation {
      name = "oslo.utils-3.8.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/1d/7c/6ba004eafc8659ddf0d8d8f4816a23f37b83cf1b54980fb28b64dd42d1f5/oslo.utils-3.8.0.tar.gz"; sha256 = "c0e935b86e72facc02264271ed09dd9c5879d52452d7a1b4a116a6c7d05077aa"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
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
      self."pytz"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://launchpad.net/oslo";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Utility library";
      };
    };

    "oslo.versionedobjects" = python.mkDerivation {
      name = "oslo.versionedobjects-1.8.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ec/dc/4e9ecff4d1049ec4cf302a924fb08ec6d6e09947bed270783ec6a69467e0/oslo.versionedobjects-1.8.0.tar.gz"; sha256 = "e727d969a5a89190783bcfa10d2c0d0bfd68d2344be3eb2f1a61ff6f63d6fd59"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."WebOb"
      self."iso8601"
      self."netaddr"
      self."oslo.concurrency"
      self."oslo.config"
      self."oslo.context"
      self."oslo.i18n"
      self."oslo.log"
      self."oslo.messaging"
      self."oslo.serialization"
      self."oslo.utils"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://launchpad.net/oslo";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Oslo Versioned Objects library";
      };
    };

    "ovs" = python.mkDerivation {
      name = "ovs-2.4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/2f/8a/358cad389613865ee255c7540f9ea2c2f98376c2d9cd723f5cf30390d928/ovs-2.4.0.tar.gz"; sha256 = "ea38287b56fd19af24dd6d1c0098ccc8ded9e8f9daeb04b152e3835278becd01"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.openvswitch.org/";
        license = licenses.asl20;
        description = "Open vSwitch library";
      };
    };

    "pbr" = python.mkDerivation {
      name = "pbr-1.8.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/94/27/2d371af70766f2d1dc0cf1c42ea3319a057d0ebc0d71ab05c824be48e9df/pbr-1.8.1.tar.gz"; sha256 = "e2127626a91e6c885db89668976db31020f0af2da728924b56480fc7ccf09649"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://launchpad.net/pbr";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Python Build Reasonableness";
      };
    };

    "pecan" = python.mkDerivation {
      name = "pecan-1.0.4";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ce/ab/faf15ad665d95241faf61c1a18fec1f5491e69908ca82229dd68ec4659c1/pecan-1.0.4.tar.gz"; sha256 = "0ecaa56bd3e1643af671dda9c293992b0e086c52cd7d19ab37bd56169a6effa8"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Mako"
      self."WebOb"
      self."WebTest"
      self."logutils"
      self."singledispatch"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/pecan/pecan";
        license = licenses.bsdOriginal;
        description = "A WSGI object-dispatching web framework, designed to be lean and fast, with few dependencies.";
      };
    };

    "pika" = python.mkDerivation {
      name = "pika-0.10.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ee/25/1517ce612d7cd0a426ea027275ba74165bbfd86a2daf4bce4839afac3deb/pika-0.10.0.tar.gz"; sha256 = "7277b4d12a99efa4058782614d84138983f9f89d690bdfcea66290d810806459"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://pika.readthedocs.org ";
        license = licenses.bsdOriginal;
        description = "Pika Python AMQP Client Library";
      };
    };

    "pika-pool" = python.mkDerivation {
      name = "pika-pool-0.1.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ec/48/50c8f02a3eef4cb824bec50661ec1713040402cc1b2a38954dc977a59c23/pika-pool-0.1.3.tar.gz"; sha256 = "f3985888cc2788cdbd293a68a8b5702a9c955db6f7b8b551aeac91e7f32da397"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pika"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/bninja/pika-pool";
        license = licenses.bsdOriginal;
        description = "Pools for pikas.";
      };
    };

    "positional" = python.mkDerivation {
      name = "positional-1.0.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/c6/8a/b0937216915330d7007dd69fb816c042904684d1e1165612b76070f4c2a2/positional-1.0.1.tar.gz"; sha256 = "54a73f3593c6e30e9cdd0a727503b7c5dddbb75fb78bb681614b08dfde2bc444"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pbr"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/morganfainberg/positional";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Library to enforce positional or key-word arguments";
      };
    };

    "prettytable" = python.mkDerivation {
      name = "prettytable-0.7.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ef/30/4b0746848746ed5941f052479e7c23d2b56d174b82f4fd34a25e389831f5/prettytable-0.7.2.tar.bz2"; sha256 = "853c116513625c738dc3ce1aee148b5b5757a86727e67eff6502c7ca59d43c36"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://code.google.com/p/prettytable";
        license = licenses.bsdOriginal;
        description = "A simple Python library for easily displaying tabular data in a visually appealing ASCII table format";
      };
    };

    "psutil" = python.mkDerivation {
      name = "psutil-1.2.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/8a/45/3b9dbd7a58482018927f756de098388ee252dd230143ddf486b3017117b1/psutil-1.2.1.tar.gz"; sha256 = "508e4a44c8253a386a0f86d9c9bd4a1b4cbb2f94e88d49a19c1513653ca66c45"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://code.google.com/p/psutil/";
        license = licenses.bsdOriginal;
        description = "A process and system utilities module for Python";
      };
    };

    "pyOpenSSL" = python.mkDerivation {
      name = "pyOpenSSL-0.15.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d4/09/002de9a836046ae1f1842e20eb7561c5b983862dd1567103e15702928a5f/pyOpenSSL-0.15.1.tar.gz"; sha256 = "f0a26070d6db0881de8bcc7846934b7c3c930d8f9c79d45883ee48984bc0d672"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."cryptography"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/pyca/pyopenssl";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Python wrapper module around the OpenSSL library";
      };
    };

    "pyasn1" = python.mkDerivation {
      name = "pyasn1-0.1.9";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f7/83/377e3dd2e95f9020dbd0dfd3c47aaa7deebe3c68d3857a4e51917146ae8b/pyasn1-0.1.9.tar.gz"; sha256 = "853cacd96d1f701ddd67aa03ecc05f51890135b7262e922710112f12a2ed2a7f"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://sourceforge.net/projects/pyasn1/";
        license = licenses.bsdOriginal;
        description = "ASN.1 types and codecs";
      };
    };

    "pyasn1-modules" = python.mkDerivation {
      name = "pyasn1-modules-0.0.8";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/60/32/7703bccdba05998e4ff04db5038a6695a93bedc45dcf491724b85b5db76a/pyasn1-modules-0.0.8.tar.gz"; sha256 = "10561934f1829bcc455c7ecdcdacdb4be5ffd3696f26f468eb6eb41e107f3837"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pyasn1"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://sourceforge.net/projects/pyasn1/";
        license = licenses.bsdOriginal;
        description = "A collection of ASN.1-based protocols modules.";
      };
    };

    "pycadf" = python.mkDerivation {
      name = "pycadf-2.2.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/2e/18/6b820a46d449a5db814289aec04466d97e18ff812e6f4b051b77bf15b092/pycadf-2.2.0.tar.gz"; sha256 = "bdb3427a28d318c6ce073b54993c2f4cc9148be498b30ad1b362ade45eb4f7fb"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."debtcollector"
      self."oslo.config"
      self."oslo.serialization"
      self."pytz"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://launchpad.net/pycadf";
        license = "License :: OSI Approved :: Apache Software License";
        description = "CADF Library";
      };
    };

    "pycparser" = python.mkDerivation {
      name = "pycparser-2.14";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/6d/31/666614af3db0acf377876d48688c5d334b6e493b96d21aa7d332169bee50/pycparser-2.14.tar.gz"; sha256 = "7959b4a74abdc27b312fed1c21e6caf9309ce0b29ea86b591fd2e99ecdf27f73"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
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
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/seb-m/pyinotify";
        license = licenses.mit;
        description = "Linux filesystem events monitoring";
      };
    };

    "pyparsing" = python.mkDerivation {
      name = "pyparsing-2.1.10";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/38/bb/bf325351dd8ab6eb3c3b7c07c3978f38b2103e2ab48d59726916907cd6fb/pyparsing-2.1.10.tar.gz"; sha256 = "811c3e7b0031021137fc83e051795025fcb98674d07eb8fe922ba4de53d39188"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pyparsing.wikispaces.com/";
        license = licenses.mit;
        description = "Python parsing module";
      };
    };

    "python-barbicanclient" = python.mkDerivation {
      name = "python-barbicanclient-4.0.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/93/3f/9ffbb6f7241d300d9a9d3f4aa794efbb1c45f6c5a729c702bec933a399cf/python-barbicanclient-4.0.1.tar.gz"; sha256 = "6dad260ddb68843fe28e8f0d106d4a4aadf766ba5131123ea18a27e9349c5d5d"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."cliff"
      self."oslo.i18n"
      self."oslo.serialization"
      self."oslo.utils"
      self."pbr"
      self."python-keystoneclient"
      self."requests"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.openstack.org/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Client Library for OpenStack Barbican Key Management API";
      };
    };

    "python-dateutil" = python.mkDerivation {
      name = "python-dateutil-2.5.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b9/d3/7800c2560d81f112417d245468b8c8d71a068d98cd13c3c14f193a297036/python-dateutil-2.5.0.tar.gz"; sha256 = "c1f7a66b0021bd7b206cc60dd47ecc91b931cdc5258972dc56b25186fa9a96a5"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://dateutil.readthedocs.org";
        license = licenses.bsdOriginal;
        description = "Extensions to the standard Python datetime module";
      };
    };

    "python-designateclient" = python.mkDerivation {
      name = "python-designateclient-2.1.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d4/14/5aa9990ed06888a1d04516915fc4ea52d032147d8c7d05839a8fdfffc936/python-designateclient-2.1.0.tar.gz"; sha256 = "ee8574e97828e0de796e5e9071da2adc1f09e1655656775a207c2d5a321ab3fa"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."cliff"
      self."debtcollector"
      self."jsonschema"
      self."oslo.utils"
      self."pbr"
      self."python-keystoneclient"
      self."requests"
      self."six"
      self."stevedore"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://launchpad.net/python-designateclient";
        license = licenses.asl20;
        description = "OpenStack DNS as a Service - Client";
      };
    };

    "python-editor" = python.mkDerivation {
      name = "python-editor-0.5";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/70/f4/61ed2565eeb4fa2aa0bd0bd70ae5883edda9f2a1d94e6702be24c6710b7b/python-editor-0.5.tar.gz"; sha256 = "f65c033ede0758663b9ff6a29d702f0b09198ad7c4ef96c9d37ccdfbf7bbf6fa"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/fmoo/python-editor";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Programmatically open an editor, capture the result.";
      };
    };

    "python-keystoneclient" = python.mkDerivation {
      name = "python-keystoneclient-2.3.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f5/da/387fef17b4e288393bbcb7d4ffe5ceae3c82f34c912e9841996651adff35/python-keystoneclient-2.3.2.tar.gz"; sha256 = "c68e34650aeab5f92d64211f9cb932e55e72878e1cc6ed7fcce20c19d0cceee6"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."debtcollector"
      self."iso8601"
      self."keystoneauth1"
      self."oslo.config"
      self."oslo.i18n"
      self."oslo.serialization"
      self."oslo.utils"
      self."pbr"
      self."positional"
      self."prettytable"
      self."requests"
      self."six"
      self."stevedore"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.openstack.org/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Client Library for OpenStack Identity";
      };
    };

    "python-neutronclient" = python.mkDerivation {
      name = "python-neutronclient-4.1.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f7/bf/ad83669669d38f86239d884dd78e5efea77353b38667a45c91ae4cc83a06/python-neutronclient-4.1.1.tar.gz"; sha256 = "4d5c60358272174afb019d68940f67ddad09367b2e6210e3206d19566777c293"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Babel"
      self."cliff"
      self."debtcollector"
      self."iso8601"
      self."keystoneauth1"
      self."netaddr"
      self."os-client-config"
      self."oslo.i18n"
      self."oslo.serialization"
      self."oslo.utils"
      self."pbr"
      self."requests"
      self."simplejson"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.openstack.org/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "CLI and Client Library for OpenStack Networking";
      };
    };

    "python-novaclient" = python.mkDerivation {
      name = "python-novaclient-3.3.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/ac/d9/b2c53ac987f0ba9c3925c98ff1c1f72c97bb81c8947554934492185c6331/python-novaclient-3.3.2.tar.gz"; sha256 = "6eba078c998d676f598925d9e6160f781e56f4b4d2afa0116c0134c326d5df49"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
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
      self."requests"
      self."simplejson"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://www.openstack.org";
        license = licenses.asl20;
        description = "Client library for OpenStack Compute API";
      };
    };

    "pytz" = python.mkDerivation {
      name = "pytz-2015.7";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/7c/bd/56dd0f51fab06520ee443146a4c7fba603fd6471f143a3942324454a33f1/pytz-2015.7.tar.bz2"; sha256 = "fbd26746772c24cb93c8b97cbdad5cb9e46c86bbdb1b9d8a743ee00e2fb1fc5d"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pythonhosted.org/pytz";
        license = licenses.mit;
        description = "World timezone definitions, modern and historical";
      };
    };

    "repoze.lru" = python.mkDerivation {
      name = "repoze.lru-0.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/6e/1e/aa15cc90217e086dc8769872c8778b409812ff036bf021b15795638939e4/repoze.lru-0.6.tar.gz"; sha256 = "0f7a323bf716d3cb6cb3910cd4fccbee0b3d3793322738566ecce163b01bbd31"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.repoze.org";
        license = "License :: Repoze Public License";
        description = "A tiny LRU cache implementation and decorator";
      };
    };

    "requests" = python.mkDerivation {
      name = "requests-2.9.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f9/6d/07c44fb1ebe04d069459a189e7dab9e4abfe9432adcd4477367c25332748/requests-2.9.1.tar.gz"; sha256 = "c577815dd00f1394203fc44eb979724b098f88264a9ef898ee45b8e5e9cf587f"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pyOpenSSL"
      self."pyasn1"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://python-requests.org";
        license = licenses.asl20;
        description = "Python HTTP for Humans.";
      };
    };

    "requestsexceptions" = python.mkDerivation {
      name = "requestsexceptions-1.1.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/09/0f/b0fa2986054805114fb185b97e270e0b8b0fd4159fa7a3791b7c61a958c9/requestsexceptions-1.1.3.tar.gz"; sha256 = "d678b872f51f76d875e00e6667f4ddbf013b3a99490ae5fe07cf3e4f846e283e"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pbr"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.openstack.org/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Import exceptions from potentially bundled packages in requests.";
      };
    };

    "retrying" = python.mkDerivation {
      name = "retrying-1.3.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/44/ef/beae4b4ef80902f22e3af073397f079c96969c69b2c7d52a57ea9ae61c9d/retrying-1.3.3.tar.gz"; sha256 = "08c039560a6da2fe4f2c426d0766e284d3b736e355f8dd24b37367b0bb41973b"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/rholder/retrying";
        license = licenses.asl20;
        description = "Retrying";
      };
    };

    "ryu" = python.mkDerivation {
      name = "ryu-4.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/25/ca/e42415c0487e047ad4fb6e1fc62cc2279f5967bab5b51c30066054ed825f/ryu-4.0.tar.gz"; sha256 = "bf6d1ad6977fb0b9ee01567fbb7a4ec28d70d14bff8fe4370b617b1228f1ee12"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."Routes"
      self."WebOb"
      self."eventlet"
      self."msgpack-python"
      self."netaddr"
      self."oslo.config"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://osrg.github.io/ryu/";
        license = licenses.asl20;
        description = "Component-based Software-defined Networking Framework";
      };
    };

    "simplejson" = python.mkDerivation {
      name = "simplejson-3.8.2";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f0/07/26b519e6ebb03c2a74989f7571e6ae6b82e9d7d81b8de6fcdbfc643c7b58/simplejson-3.8.2.tar.gz"; sha256 = "d58439c548433adcda98e695be53e526ba940a4b9c44fb9a05d92cd495cdd47f"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://github.com/simplejson/simplejson";
        license = licenses.mit;
        description = "Simple, fast, extensible JSON encoder/decoder for Python";
      };
    };

    "singledispatch" = python.mkDerivation {
      name = "singledispatch-3.4.0.3";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/d9/e9/513ad8dc17210db12cb14f2d4d190d618fb87dd38814203ea71c87ba5b68/singledispatch-3.4.0.3.tar.gz"; sha256 = "5b06af87df13818d14f08a028e42f566640aef80805c3b50c5056b086e3c2b9c"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://docs.python.org/3/library/functools.html#functools.singledispatch";
        license = licenses.mit;
        description = "This library brings functools.singledispatch from Python 3.4 to Python 2.6-3.3.";
      };
    };

    "six" = python.mkDerivation {
      name = "six-1.10.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/b3/b2/238e2590826bfdd113244a40d9d3eb26918bd798fc187e2360a8367068db/six-1.10.0.tar.gz"; sha256 = "105f8d68616f8248e24bf0e9372ef04d3cc10104f1980f54d57b2ce73a5ad56a"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://pypi.python.org/pypi/six/";
        license = licenses.mit;
        description = "Python 2 and 3 compatibility utilities";
      };
    };

    "sqlalchemy-migrate" = python.mkDerivation {
      name = "sqlalchemy-migrate-0.10.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/83/c8/c9b30792222210e0c19c7dfc26ea3b777382417ea48ae9d9d02619de81ac/sqlalchemy-migrate-0.10.0.tar.gz"; sha256 = "f83c5cce9c09e5c05527279b7fe1565b32e5353342ff30b24f594fa2e5a7e003"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."SQLAlchemy"
      self."Tempita"
      self."decorator"
      self."pbr"
      self."six"
      self."sqlparse"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://www.openstack.org/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Database schema migration for SQLAlchemy";
      };
    };

    "sqlparse" = python.mkDerivation {
      name = "sqlparse-0.1.18";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/85/7d/0d217b6132f1dd3fd22d1b1fbc16bb9fd951f5c1a3af814bb8a22edc5da3/sqlparse-0.1.18.tar.gz"; sha256 = "39b196c4a06f76d6ac82f029457ca961f662a8bbbb2694eb1dfe4f2b68a2d7cf"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/andialbrecht/sqlparse";
        license = licenses.bsdOriginal;
        description = "Non-validating SQL parser";
      };
    };

    "stevedore" = python.mkDerivation {
      name = "stevedore-1.12.0";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/f0/b1/5659992d66cd7f11a8c1ab0f8fead649ac05fe2c8f673cdf3f70593ff175/stevedore-1.12.0.tar.gz"; sha256 = "1bdeb2562d8f2c1e3047c2f17134a38b37a6e53e16ca1d9f79ff2ac5d5fe2925"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [
      self."pbr"
      self."six"
    ];
      meta = with pkgs.stdenv.lib; {
        homepage = "http://docs.openstack.org/developer/stevedore/";
        license = "License :: OSI Approved :: Apache Software License";
        description = "Manage dynamic plugins for Python applications";
      };
    };

    "unicodecsv" = python.mkDerivation {
      name = "unicodecsv-0.14.1";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/6f/a4/691ab63b17505a26096608cc309960b5a6bdf39e4ba1a793d5f9b1a53270/unicodecsv-0.14.1.tar.gz"; sha256 = "018c08037d48649a0412063ff4eda26eaa81eff1546dbffa51fa5293276ff7fc"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/jdunck/python-unicodecsv";
        license = licenses.bsdOriginal;
        description = "Python2's stdlib csv module is nice, but it doesn't support unicode. This module is a drop-in replacement which *does*.";
      };
    };

    "waitress" = python.mkDerivation {
      name = "waitress-0.8.10";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/05/a1/56049f664a045fd7f789d0d291d3b2f97d6ad095b2ff2d6a07e0ad0c2a9b/waitress-0.8.10.tar.gz"; sha256 = "7c40c1af0f0c254edb25153621a1e825bc1af2f7bf41a74b4bb8ee6d544ef604"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
      buildInputs = commonBuildInputs;
      propagatedBuildInputs = [ ];
      meta = with pkgs.stdenv.lib; {
        homepage = "https://github.com/Pylons/waitress";
        license = licenses.zpl21;
        description = "Waitress WSGI server";
      };
    };

    "wrapt" = python.mkDerivation {
      name = "wrapt-1.10.6";
      src = pkgs.fetchurl { url = "https://files.pythonhosted.org/packages/0f/94/0862c5e97a818aa6053a1a376364c664aa050e09cb65e18bd11f414c978a/wrapt-1.10.6.tar.gz"; sha256 = "9576869bb74a43cbb36ee39dc3584e6830b8e5c788e83edf0a397eba807734ab"; };
      doCheck = commonDoCheck;
      checkPhase = "";
      installCheckPhase = "";
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
  localOverrides = import localOverridesFile { inherit pkgs python; };
  commonOverrides = [
    
  ];
  paramOverrides = [
    (overrides { inherit pkgs python; })
  ];
  allOverrides =
    (if (builtins.pathExists localOverridesFile)
     then [localOverrides] else [] ) ++ commonOverrides ++ paramOverrides;

in python.withPackages
   (fix' (pkgs.lib.fold
            extends
            generated
            allOverrides
         )
   )