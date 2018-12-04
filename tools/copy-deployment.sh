#! /usr/bin/env nix-shell
#! nix-shell -p jq yq git -i bash

set -e

[ $# -lt 3 ] && echo "Usage: $0 APP ENV DEST" && exit 1

cd $(dirname ${BASH_SOURCE[0]})

APP=$1
ENV=$2
DEST=$3
CURRENT_REV=$(git rev-parse HEAD)

mkdir -p $DEST

_copy_file() {
  local SRC=$1
  local NAME=$(basename $1)
  echo -n "Creating ${DEST}/${NAME}..."
  cat $SRC \
    | yq . \
    | jq ".items[].metadata.labels.\"nixpkgs-cloudwatt\" |= \"${CURRENT_REV}\"" \
    | yq . -y \
    > ${DEST}/${NAME}
  echo -e "\rCreated ${DEST}/${NAME}     "
}

echo -n "Building deployment..."
DEPLOYMENT=$(nix-build ../default.nix -A k8sDeployments.${APP}.${ENV})
echo -e "\rDeployment builded.   "
if [ -d $DEPLOYMENT ]; then
    for DEPLOYMENT_FILE in $(ls $DEPLOYMENT)
    do
        _copy_file $DEPLOYMENT/$DEPLOYMENT_FILE
    done
elif [ -f $DEPLOYMENT ]; then
    _copy_file $DEPLOYMENT
else
    echo "No directory for file produced by nix-build. Exiting"
    exit 1
fi
