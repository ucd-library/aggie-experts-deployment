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

docker compose -f compose/$VERSION/compose.yaml -p aggie-experts up --scale dagster-celery-worker=2 -d

echo "Aggie Experts deployment ($VERSION) is up and running."
echo " - Harvest (Anduin) URL  : http://localhost:4000"
echo " - App URL               : http://localhost:8080"