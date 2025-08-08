#! /bin/bash

KNOWN_VERSIONS=("prod" "stage" "local-dev")
VERSION=$1

if [[ ! " ${KNOWN_VERSIONS[@]} " =~ " ${VERSION} " ]]; then
  echo "Unknown version: $VERSION"
  echo "Known versions are: ${KNOWN_VERSIONS[*]}"
  exit 1
fi

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..

docker compose -f compose/$VERSION/harvest.yaml -p aggie-experts-harvest up -d
docker compose -f compose/$VERSION/app.yaml -p aggie-experts-app up -d