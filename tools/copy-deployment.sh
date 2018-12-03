#! /usr/bin/env nix-shell
#! nix-shell -p jq yq git -i bash

[ $# -lt 3 ] && echo "Usage: $0 APP ENV DEST [DEPLOYMENT]" && exit 1

cd $(dirname ${BASH_SOURCE[0]})

APP=$1
ENV=$2
DEST=$3
DEPLOYMENT=$4
CURRENT_REV=$(git rev-parse HEAD)

mkdir -p $DEST

_gen_deployment () {
  local deployment=$1
  # convert attribute name to snake case
  NAME=$(sed -e 's/\([A-Z]\)/-\L\1/g' <<< $deployment)
  echo -n "Building ${DEST}/${NAME}.yml..."
  cat $(nix-build -A k8sDeployments.${APP}.${ENV}.${deployment} ../default.nix) \
    | jq ".items[].metadata.labels.\"nixpkgs-cloudwatt\" |= \"${CURRENT_REV}\"" \
    | yq . -y \
    > ${DEST}/${NAME}.yml
  echo -e "\rBuilded ${DEST}/${NAME}.yml      "
}

if [ ! -z $DEPLOYMENT ]; then
    _gen_deployment $DEPLOYMENT
else
    DEPLOYMENTS=$(nix-instantiate -E "with (import ../default.nix {}); with builtins; concatStringsSep \" \" (attrNames k8sDeployments.${APP}.${ENV})" --eval | tr -d \")
    for DEPLOYMENT in $DEPLOYMENTS; do
        _gen_deployment $DEPLOYMENT
    done
fi
