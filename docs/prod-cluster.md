# Production Cluster (Docker Compose)

Production runs on `experts-anduin.library.ucdavis.edu` as a Docker Compose stack managed by a systemd service.

## Prerequisites

- SSH access to `experts-anduin.library.ucdavis.edu`
- Service account JSON and environment credentials — contact the project lead

## First-Time Server Setup

### 1. SSH to the server

```bash
ssh experts-anduin.library.ucdavis.edu
```

### 2. Clone this repository

```bash
sudo mkdir -p /opt/aggie-experts-deployment
sudo chown $USER /opt/aggie-experts-deployment
git clone https://github.com/ucd-library/aggie-experts-deployment /opt/aggie-experts-deployment
cd /opt/aggie-experts-deployment
```

### 3. Configure credentials

Place the service account JSON and populate the environment file. Contact the project lead for the required values.

Files needed:

- `compose/prod/service-account.json` — GCP service account with access to GCS buckets and Secret Manager
- `compose/prod/.env` — environment variables including OIDC client secret, JWT secret, Superset secret key, and Slack webhook URL

These files are git-ignored and must be provisioned manually. Reference the dev environment for the full list of required variables, but use production-specific values.

### 4. Pull images

```bash
cd /opt/aggie-experts-deployment/compose/prod
docker compose -p aggie-experts pull
```

### 5. Enable the systemd service

```bash
sudo systemctl enable /opt/aggie-experts-deployment/compose/prod/systemd/aggie-experts.service
```

### 7. Start the service

```bash
sudo service aggie-experts start
```

The systemd unit starts the stack with 3 Dagster Celery workers and restarts it automatically on server reboot.

### 8. Initialize databases (first run only)

After all containers are healthy, initialize Elasticsearch indexes, the PostgreSQL schema, Dagster metadata, and the CaskFS cache:

```bash
docker compose -p aggie-experts exec dagster-celery-worker experts init
```

## Updating Production

See [Updating Deployments](updating-deployments.md) for the full release workflow. Once image tags in this repo have been updated and pushed, deploy on the server:

```bash
ssh experts-anduin.library.ucdavis.edu
cd /opt/aggie-experts-deployment/compose/prod
./update-cluster.sh webapp    # zero-downtime rolling restart of webapp services
./update-cluster.sh anduin    # rolling restart of ETL stack (brief interruption to harvest)
./update-cluster.sh all       # full restart — use only when postgres/elasticsearch must restart
```

`update-cluster.sh` automatically runs `git pull` and `docker compose pull` before restarting services.

### Service Groups

| Group | Services | Notes |
|---|---|---|
| `webapp` | webapp-gateway, spa, api | Zero-downtime rolling restart |
| `anduin` | dagster-daemon, dagster-celery-worker, dagster-ui, anduin-gateway, caskfs-ui, superset | Brief ETL interruption; does not affect public webapp |
| `all` | everything | Brief downtime; only needed when postgres or elasticsearch must restart |

## Stopping and Starting Manually

```bash
sudo service aggie-experts stop
sudo service aggie-experts start
```

## Viewing Logs

```bash
docker compose -p aggie-experts logs -f
docker compose -p aggie-experts logs -f dagster-celery-worker
```
