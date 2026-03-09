#! /bin/bash

set -e

HOST=https://experts-anduin.library.ucdavis.edu
SERVICE_GROUP=$1
ALLOWED_SERVICE_GROUPS=("webapp" "anduin" "all")
USERNAME=$USERNAME

if [[ -z "$SERVICE_GROUP" ]]; then
  echo "Usage: $0 <service-group>"
  echo "Example: $0 webapp"
  exit 1
fi

if [[ ! " ${ALLOWED_SERVICE_GROUPS[@]} " =~ " ${SERVICE_GROUP} " ]]; then
  echo "Error: Invalid service group. Allowed service groups are: ${ALLOWED_SERVICE_GROUPS[@]}"
  echo "Usage: $0 <service-group>"
  echo "Example: $0 webapp"
  exit 1
fi

ssh $USERNAME@aggie-experts "cd /opt/aggie-experts-deployment/compose/prod/update-cluster.sh $SERVICE_GROUP"