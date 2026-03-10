#! /bin/bash

PROJECT_NAME=aggie-experts
SERVICE_GROUP=$1
WORKER_COUNT=3
ALLOWED_SERVICE_GROUPS=("webapp" "anduin" "all")
WEBAPP_SERVICES=("webapp-gateway" "spa" "api")
ANDUIN_SERVICES=("dagster-daemon" "dagster-celery-worker" "dagster-ui" "anduin-gateway" "caskfs-ui" "superset")

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

set -e

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR

git pull
docker compose -p $PROJECT_NAME pull

# full restart
if [[ "$SERVICE_GROUP" == "all" ]]; then
  echo "Performing full restart (down/up) of all services"
  docker compose -p $PROJECT_NAME down
  docker compose -p $PROJECT_NAME up --scale dagster-celery-worker=$WORKER_COUNT -d

# attempt to do a rolling restart of just the webapp
elif [[ "$SERVICE_GROUP" == "webapp" ]]; then
  echo "Performing rolling restart of webapp services: ${WEBAPP_SERVICES[@]}"
  docker compose -p $PROJECT_NAME up --no-deps -d ${WEBAPP_SERVICES[@]} 

# for the anduin services
elif [[ "$SERVICE_GROUP" == "anduin" ]]; then
  echo "Performing rolling restart of anduin services: ${ANDUIN_SERVICES[@]}"
  docker compose -p $PROJECT_NAME up --no-deps -d ${ANDUIN_SERVICES[@]} 
if