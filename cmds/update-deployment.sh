#! /bin/bash

set -e

ENVIRONMENT=$1
AE_VERSION=$2

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..

ALLOWED_ENVIRONMENTS=("dev" "sandbox" "prod")

LIBRARY_DEV_K8S="dev-libk8s"

OS_REGISTRY="us-west1-docker.pkg.dev/digital-ucdavis-edu/pub"
AE_REGISTRY="us-west1-docker.pkg.dev/aggie-experts/pub"
AE_BUILD_REGISTRY_URL="https://raw.githubusercontent.com/ucd-library/cork-build-registry/refs/heads/main/repositories/aggie-experts.json"
ANDUIN_BUILD_REGISTRY_URL="https://raw.githubusercontent.com/ucd-library/cork-build-registry/refs/heads/main/repositories/project-anduin.json"

if [[ ! " ${ALLOWED_ENVIRONMENTS[@]} " =~ " ${ENVIRONMENT} " ]]; then
  echo "Error: Invalid environment. Allowed environments are: ${ALLOWED_ENVIRONMENTS[@]}"
  echo "Usage: $0 <environment> <version>"
  exit 1
fi

if [[ -z "$AE_VERSION" ]]; then
  echo "Usage: $0 <environment> <version>"
  exit 1
fi

edit() {
  ROOT=$1
  RESOURCE_TYPE=$2
  IMAGE=$3
  CONTAINER=$4
  OVERLAY=$5

  if [[  "$OVERLAY" ]]; then
    echo "Updating $ROOT resource=$RESOURCE_TYPE container=$CONTAINER image=$IMAGE overlay=$OVERLAY"
    OVERLAY="-o $OVERLAY"
  else
    echo "Updating $ROOT resource=$RESOURCE_TYPE container=$CONTAINER image=$IMAGE for base"
  fi

  cork-kube edit $OVERLAY \
    -f $RESOURCE_TYPE \
    -e "\$.spec.template.spec.containers[?(@.name==\"$CONTAINER\")].image=$IMAGE" \
    --replace \
    -- kustomize/$ROOT
}

JSON_DATA=$(curl -s $AE_BUILD_REGISTRY_URL)
CASKFS_VERSION=$(echo $JSON_DATA | jq -r ".builds[\"$AE_VERSION\"].caskfs")
ANDUIN_VERSION=$(echo $JSON_DATA | jq -r ".builds[\"$AE_VERSION\"][\"project-anduin\"]")
JSON_DATA=$(curl -s $ANDUIN_BUILD_REGISTRY_URL)
POSTGRES_VERSION=$(echo $JSON_DATA | jq -r ".builds[\"$ANDUIN_VERSION\"].postgres")

echo "Updating Aggie Experts to version: $AE_VERSION (CaskFS: $CASKFS_VERSION, Anduin: $ANDUIN_VERSION, Postgres: $POSTGRES_VERSION)"

edit postgres statefulset "$OS_REGISTRY/anduin-pg:$ANDUIN_VERSION" database ${ENVIRONMENT}
edit elastic-search statefulset "$AE_REGISTRY/elastic-search:$AE_VERSION" elasticsearch ${ENVIRONMENT}

edit anduin-gateway deployment "$AE_REGISTRY/anduin-gateway:$AE_VERSION" service ${ENVIRONMENT}
edit caskfs-ui deployment "$AE_REGISTRY/harvest:$AE_VERSION" service ${ENVIRONMENT}
edit dagster/dagster-code-server deployment "$AE_REGISTRY/harvest:$AE_VERSION" service ${ENVIRONMENT}
edit dagster/dagster-daemon deployment "$AE_REGISTRY/harvest:$AE_VERSION" service ${ENVIRONMENT}
edit dagster/dagster-ui deployment "$AE_REGISTRY/harvest:$AE_VERSION" service ${ENVIRONMENT}
edit superset statefulset "$OS_REGISTRY/superset:$ANDUIN_VERSION" service ${ENVIRONMENT}