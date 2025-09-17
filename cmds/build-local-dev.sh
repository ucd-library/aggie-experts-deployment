#! /bin/bash

VERSION=$1
if [[ -z "$VERSION" ]]; then
  VERSION="anduin"
fi

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..

ENV_FILE=./compose/local-dev/.env

cork-kube build exec \
  -p fin \
  -v 2.12.0 \
  -o sandbox \
  --set-env $ENV_FILE \
  -f fin-elastic-search

cork-kube build exec \
  -p project-anduin \
  -v main \
  -o sandbox \
  --depth ALL \
  --set-env $ENV_FILE

cork-kube build exec \
  -p aggie-experts \
  -v $VERSION \
  --set-env $ENV_FILE \
  -o sandbox