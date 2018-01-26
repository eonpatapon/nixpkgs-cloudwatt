pkgs:

rec {
  # We use environment variables REGISTRY_URL, REGISTRY_USERNAME,
  # REGISTRY_PASSWORD to specify the url and credentials of the
  # registry.
  # The commit ID is used to generate the image tag.
  dockerPushImage = image: commitId:
    let
      imageRef = "${image.imageName}:${commitId}-${builtins.baseNameOf image.out}";
      jobName = with pkgs.lib; "push-" + (removeSuffix ".tar" (removeSuffix ".gz" image.name));
      outputString = "Pushed image ${image.imageName} with content ${builtins.baseNameOf image.out}" ;
    in
      pkgs.runCommand jobName {
        buildInputs = with pkgs; [ jq skopeo ];
        impureEnvVars = pkgs.stdenv.lib.fetchers.proxyImpureEnvVars ++
          [ "REGISTRY_URL" "REGISTRY_USERNAME" "REGISTRY_PASSWORD" ];
        outputHashMode = "flat";
        outputHashAlgo = "sha256";
        outputHash = builtins.hashString "sha256" outputString;
      } ''
      DESTCREDS=""
      CREDS=""
      if [ ! -z $REGISTRY_USERNAME ] && [ ! -z $REGISTRY_USERNAME ]; then
        DESTCREDS="--dest-creds $REGISTRY_USERNAME:$REGISTRY_PASSWORD"
        CREDS="--creds $REGISTRY_USERNAME:$REGISTRY_PASSWORD"
      fi
      if [ -z $REGISTRY_URL ]; then
        REGISTRY_URL="localhost:5000"
      fi

      echo "Ungunzip image (since skopeo doesn't support tgz image)..."
      gzip -d ${image.out} -c > image.tar
      echo "Pushing unzipped image ${image.out} ($(du -hs image.tar | cut -f1)) to registry $REGISTRY_URL/${imageRef} ..."
      skopeo --insecure-policy copy $DESTCREDS --dest-tls-verify=false --dest-cert-dir=/tmp docker-archive:image.tar docker://$REGISTRY_URL/${imageRef}
      skopeo --insecure-policy inspect $CREDS --tls-verify=false --cert-dir=/tmp docker://$REGISTRY_URL/${imageRef}
      echo -n ${outputString} > $out
    '';

  genPerpRcMain = { name, executable, preStartScript ? "", cwd ? "" }: pkgs.writeTextFile {
    name = "${name}-rc.main";
    executable = true;
    destination = "/etc/perp/${name}/rc.main";
    text = ''
      #!${pkgs.bash}/bin/bash

      exec 2>&1

      TARGET=$1
      SVNAME=$2

      ${preStartScript}

      OPTIONS=""
      [ "${cwd}" != "" ] && OPTIONS="$OPTIONS -c ${cwd}"

      start() {
        exec runtool $OPTIONS ${executable}
      }

      reset() {
        exit 0
      }

      eval $TARGET "$@"
    '';
  };

  # Build an image where 'command' is started by Perp
  buildImageWithPerp = { name, fromImage, executable, preStartScript ? "", extraCommands ? "" }: buildImageWithPerps {
    inherit name fromImage extraCommands;
    services = [
      { inherit preStartScript executable; name = builtins.replaceStrings ["/"] ["-"] name; }
    ];
  };

  buildImageWithPerps = { name, fromImage, services, extraCommands ? "" }: pkgs.dockerTools.buildImage {
    inherit name fromImage;
    config = {
      Cmd = [ "/usr/sbin/perpd" ];
    };
    contents = map genPerpRcMain services;
    extraCommands = ''
      ${pkgs.findutils}/bin/find etc/perp -type d -exec chmod +t {} \;
    '' + extraCommands;
  };

}
