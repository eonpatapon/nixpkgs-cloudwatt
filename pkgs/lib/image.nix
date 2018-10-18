{ pkgs, lib }:

rec {
  # We use environment variables REGISTRY_URL, REGISTRY_USERNAME,
  # REGISTRY_PASSWORD to specify the url and credentials of the
  # registry.
  # The commit ID is used to generate the image tag.
  #
  # We push the image two times, with and without the commit id. The
  # tag with the commit id provides a way to find back which commit of
  # nixpkgs-cloudwatt has been used to create this image while the tag
  # without the commit id is a stable identifier across both CIs.
  dockerPushImage = image: commitId: unsetProxy:
    let
      imageRefWithCommitId = "${image.imageName}:${commitId}-${builtins.baseNameOf image.out}";
      # Generate a ref such as imageName:outputPathHash
      imageRef = image.imageName + ":" + pkgs.lib.removeSuffix ("-" + image.name) (builtins.baseNameOf image.out);
      jobName = with pkgs.lib; "push-" + (removeSuffix ".tar" (removeSuffix ".gz" image.name));
      outputString = "Pushed image ${image.imageName} with content ${builtins.baseNameOf image.out}  ";
    in
      pkgs.runCommand jobName {
        buildInputs = with pkgs; [ jq skopeo ];
        impureEnvVars = pkgs.lib.optionals (!unsetProxy) pkgs.stdenv.lib.fetchers.proxyImpureEnvVars ++
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
      echo "Pushing unzipped image ${image.out} ($(du -hs image.tar | cut -f1)) to registry $REGISTRY_URL/${imageRefWithCommitId} ..."
      skopeo --insecure-policy copy $DESTCREDS --dest-tls-verify=false --dest-cert-dir=/tmp docker-archive:image.tar docker://$REGISTRY_URL/${imageRefWithCommitId}
      echo "Pushing unzipped image ${image.out} ($(du -hs image.tar | cut -f1)) to registry $REGISTRY_URL/${imageRef} ..."
      skopeo --insecure-policy copy $DESTCREDS --dest-tls-verify=false --dest-cert-dir=/tmp docker-archive:image.tar docker://$REGISTRY_URL/${imageRef}
      skopeo --insecure-policy inspect $CREDS --tls-verify=false --cert-dir=/tmp docker://$REGISTRY_URL/${imageRef}
      echo -n "${outputString}" > $out
    '';

  runOptions = { chdir ? "", command, ... }@args:
    if chdir != "" then
      args // { command = "exec runtool -c ${chdir} ${command}"; }
    else
      args // { command = "exec ${command}"; };

  runOneShot = { oneShot ? false, name, command, ... }@args:
    let
      oneshot = pkgs.writeShellScriptBin "oneshot-${name}" ''
        ${command}
        ret=$?
        [ $ret -eq 0 ] && touch /var/run/perp/${name}.success || touch /var/run/perp/${name}.fail
        exit $ret
      '';
    in
      if oneShot then
        args // { command = "${oneshot}/bin/oneshot-${name}"; }
      else args;

  runAsUser = { user ? "nobody", command, ... }@args:
    if user != "nobody" && user != "root" then
      abort "Only nobody and root users are supported."
    else
      args // { command = "runuid ${user} ${command}"; };

  runPreScript = { preStartScript ? "", command, name, ... }@args:
    let
      start = pkgs.writeShellScriptBin "start-${name}" ''
        set -e
        ${preStartScript}
        exec ${command}
      '';
    in
      if preStartScript != "" then
        args // { command = "${start}/bin/start-${name}"; }
      else args;

  runWithEnv = { environmentFile ? "", command, ... }@args:
    if environmentFile != "" then
      args // { command = "runenv ${environmentFile} ${command}"; }
    else args;

  genPerpRcLog = { name, logger, ... }: pkgs.writeTextFile {
    name = "${name}-rc.log";
    destination = "/etc/perp/${name}/rc.log";
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash

      exec 2>&1

      TARGET=$1

      start() {
        ${logger}
      }

      eval $TARGET "$@"
    '';
  };

  genPerpRcMain = {
    name,
    command,
    preStartScript ? "",
    chdir ? "",
    oneShot ? false,
    user ? "nobody",
    environmentFile ? "",
    after ? [],
    ...
  }@args:
    let
      newArgs = runOptions (runOneShot (runAsUser (runPreScript (runWithEnv args))));
      oneShotScript = pkgs.lib.optionalString oneShot ''
        if [ -f /var/run/perp/${name}.started ]; then
          echo "Disable the oneshot perp service ${name} since it has been already executed"
          perpctl X $SVNAME
          rm /var/run/perp/${name}.started
          exit 0
        fi
        touch /var/run/perp/${name}.started
      '';
      checkServiceUp = name: ''
        echo [${args.name}] Waiting for ${name} to be up...
        while :
        do
          [ -f /var/run/perp/${name}.success ] && break
          [ -f /var/run/perp/${name}.fail ] && echo [${args.name}] ${name} did not run properly.
          perpok -b /etc/perp -u 3 ${name} && break
          sleep 2
        done
        echo [${args.name}] Starting.
      '';
    in
      pkgs.writeTextFile {
        name = "${name}-rc.main";
        executable = true;
        destination = "/etc/perp/${name}/rc.main";
        text = ''
          #!${pkgs.bash}/bin/bash

          exec 2>&1

          TARGET=$1
          SVNAME=$2

          ${pkgs.lib.concatStringsSep "" (map checkServiceUp after)}

          ${oneShotScript}

          start() {
            ${newArgs.command}
          }

          reset() {
            exit 0
          }

          eval $TARGET "$@"
        '';
      };

  # Build an image where 'command' is started by Perp
  buildImageWithPerp = {
    name,
    fromImage ? pkgs.dockerImages.pulled.kubernetesBaseImage,
    command,
    preStartScript ? "",
    contents ? [],
    extraCommands ? "",
    user ? "nobody",
    environmentFile ? "",
    fluentd ? {},
  }:
    buildImageWithPerps {
      inherit name fromImage contents extraCommands;
      services = [
        {
          inherit preStartScript command user environmentFile fluentd;
          name = builtins.replaceStrings ["/"] ["-"] name;
        }
      ];
    };

  buildImageWithPerps = args@{
    name,
    fromImage ? pkgs.dockerImages.pulled.kubernetesBaseImage,
    services,
    contents ? [],
    extraCommands ? "",
    runAsRoot ? null
  }:
    let
      newArgs = lib.fluentd.insertFluentd args;
    in
      pkgs.dockerTools.buildImage {
        inherit name runAsRoot;
        tag = "latest";
        fromImage =
          if newArgs ? fromImage then
            newArgs.fromImage
          else
            pkgs.dockerImages.pulled.kubernetesBaseImage;
        config = {
          Cmd = [ "/usr/sbin/perpd" ];
        };
        contents = map genPerpRcMain newArgs.services
          ++ map genPerpRcLog (builtins.filter (s: s ? "logger") newArgs.services)
          ++ contents;
        extraCommands = ''
          ${pkgs.findutils}/bin/find etc/perp -type d -exec chmod +t {} \;
        '' + extraCommands;
      };

  # This helper takes a Docker Compose file to generate a script that
  # loads Docker images used by this stack and run docker compose.  Be
  # careful, to provide the image, you have to use the basename of the
  # output path. For instance:
  #    ...
  #    container = {
  #      image = builtins.baseNameOf myImage;
  #    ...
  runDockerComposeStack = stack:
    let
      dockerComposeFile = pkgs.writeTextFile {
        name = "docker-compose.yaml";
        text = pkgs.lib.generators.toYAML {} stack;
      };
    in
      pkgs.writeScript "run-docker-compose-stack" ''
        images=$(cat ${pkgs.writeReferencesToFile dockerComposeFile} | grep -v ${dockerComposeFile})
        for i in $images; do
          echo "docker load -i $i ..."
          imageRef=$(${pkgs.docker}/bin/docker load -i $i | grep "Loaded image" | sed 's/Loaded image: \(.*\)/\1/')
          echo "docker tag $imageRef $(basename $i)"
          ${pkgs.docker}/bin/docker tag $imageRef $(basename $i)
        done
        echo "docker-compose -f ${dockerComposeFile} up -d ..."
        ${pkgs.docker_compose}/bin/docker-compose -f ${dockerComposeFile} up -d
        echo
        echo "To get container logs:"
        echo "  ${pkgs.docker_compose}/bin/docker-compose -f ${dockerComposeFile} logs -f"
        echo "To destroy the stack:"
        echo "  ${pkgs.docker_compose}/bin/docker-compose -f ${dockerComposeFile} down"
      '';

  myIp = ''
    # hack to populate the configuration with the container ip
    # with consul-template it is only possible to read a file
    [[ ! -f /my-ip ]] && hostname --ip-address > /my-ip
    '';
}
