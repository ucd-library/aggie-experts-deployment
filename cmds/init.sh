#! /bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..

if [ ! -f "service-account.json" ]; then
    echo "Fetching service account JSON..."
    gcloud --project aggie-experts secrets versions access latest --secret=local-dev-service-account > service-account.json
else
    echo "service-account.json already exists."
fi

# Check if SUPERSET_SECRET_KEY exists in .env file
ENV_FILE="compose/local-dev/.env"
if [ ! -f "$ENV_FILE" ]; then
    echo "Creating $ENV_FILE"
    mkdir -p "$(dirname "$ENV_FILE")"
    touch "$ENV_FILE"
fi

if ! grep -q "SUPERSET_SECRET_KEY=" "$ENV_FILE"; then
    echo "Generating SUPERSET_SECRET_KEY..."
    SECRET_KEY=$(openssl rand -base64 42)
    echo -e "\nSUPERSET_SECRET_KEY=$SECRET_KEY" >> "$ENV_FILE"
    echo "SUPERSET_SECRET_KEY added to $ENV_FILE"
else
    echo "SUPERSET_SECRET_KEY already exists in $ENV_FILE"
fi

if ! grep -q "KEYCLOAK_CLIENT_SECRET=" "$ENV_FILE"; then
    echo "Fetching KEYCLOAK_CLIENT_SECRET..."
    SECRET_KEY=$(gcloud --project aggie-experts secrets versions access latest --secret=keycloak-anduin-client-secret)
    echo -e "\nKEYCLOAK_CLIENT_SECRET=$SECRET_KEY" >> "$ENV_FILE"
    echo "KEYCLOAK_CLIENT_SECRET added to $ENV_FILE"
else
    echo "KEYCLOAK_CLIENT_SECRET already exists in $ENV_FILE"
fi