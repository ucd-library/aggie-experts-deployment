#! /bin/bash


KNOWN_CLUSTERS=("app" "harvest" "all")


# CLUSTER=${1:-harvest}
OPTION=${1:-''}

# if [[ ! " ${KNOWN_VERSIONS[@]} " =~ " ${VERSION} " ]]; then
#   echo "Unknown version: $VERSION"
#   echo "Known versions are: ${KNOWN_VERSIONS[*]}"
#   exit 1
# fi


docker compose -p aggie-experts-harvest down $OPTION
docker compose -p aggie-experts-app down $OPTION