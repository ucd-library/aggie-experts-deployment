# Local Development

Runs the full Aggie Experts stack on your machine using Docker Compose with source code mounted into containers, so code changes are reflected without rebuilding images.

## Prerequisites

- [cork-kube](prerequisites.md#cork-kube) installed
- [gcloud CLI](prerequisites.md#gcloud-cli) installed
- Docker Desktop (or equivalent) running
- GCP access to project `aggie-experts`

## Directory Structure

The local dev compose mounts source code from sibling repositories. Check them out alongside this repo so the paths resolve correctly:

```
~/dev/                              # or wherever you keep projects
  library/
    aggie-experts/
      aggie-experts/                # application source (aggie-experts repo)
      aggie-experts-deployment/     # this repo
    project-anduin/                 # project-anduin repo
    caskfs/                         # caskfs repo
```

Clone the dependencies (from the root of this repo):

```bash
# sibling of this repo, one level up
git clone https://github.com/ucd-library/aggie-experts ../aggie-experts

# two levels up — siblings of the aggie-experts parent folder
git clone https://github.com/ucd-library/project-anduin ../../project-anduin
git clone https://github.com/ucd-library/caskfs ../../caskfs
```

## First-Time Setup

### 1. Register the project with cork-kube

From the root of this repo:

```bash
cork-kube project set -c .cork-kube-config
cork-kube project set -e [your-email-address]
```

### 2. Initialize secrets

Fetches the service account JSON and OIDC client secret from GCP Secret Manager and writes them to `compose/local-dev/.env`. Generates a Superset secret key locally.

```bash
./cmds/init.sh
```

This requires GCP access to project `aggie-experts`. If you receive an auth error, run `gcloud auth login` first.

### 3. Build local images

Builds sandbox images for `aggie-experts`, `project-anduin`, and `caskfs` using Google Cloud Build and tags them for local use. Accepts an optional version argument (defaults to `anduin`):

```bash
./cmds/build-local-dev.sh
# or with a specific version branch/tag:
./cmds/build-local-dev.sh main
```

This may take several minutes on first run.

### 4. Start the stack

```bash
./cmds/up.sh local-dev
```

Starts all services with 2 Dagster Celery workers. Once running:

| Service | URL |
|---|---|
| Anduin gateway (Dagster, CaskFS, Superset, Kibana) | http://localhost:4000 |
| Aggie Experts webapp | http://localhost:8080 |
| RabbitMQ management UI | http://localhost:15672 |
| Elasticsearch | http://localhost:9200 |
| Kibana | http://localhost:5601 |

### 5. Initialize databases (first run only)

After the stack is up and all containers are healthy, initialize the Elasticsearch indexes, PostgreSQL schema, Dagster metadata database, and CaskFS cache:

```bash
docker compose -p aggie-experts exec dagster-celery-worker experts init
```

This is only required on the first start or after a full data wipe.

## Stopping

```bash
./cmds/down.sh local-dev
```

## Subsequent Starts

After first-time setup, simply start and stop the stack:

```bash
./cmds/up.sh local-dev
./cmds/down.sh local-dev
```

Secrets and built images persist between restarts. Re-run `./cmds/build-local-dev.sh` when you need to pick up new image builds.

## VS Code Tasks

If you use VS Code, `.vscode/tasks.json` defines several tasks that wrap the common commands. Open the command palette with `Cmd+Shift+P` (Mac) or `Ctrl+Shift+P` (Windows/Linux), select **Tasks: Run Task**, and choose from:

> **Tip:** Add a custom keybinding to open the task menu directly with `Cmd+Shift+T`. Open `keybindings.json` via **Code → Preferences → Keyboard Shortcuts**, click the `{}` icon in the top-right to edit the JSON file, and add:
> ```json
> {
>   "key": "cmd+shift+t",
>   "command": "workbench.action.tasks.runTask"
> }
> ```

| Task | Description |
|---|---|
| **Build Local Dev Cluster** | Runs `./cmds/build-local-dev.sh` |
| **Start Local Dev Cluster** | Runs `./cmds/up.sh local-dev` |
| **Stop Local Dev Cluster** | Runs `./cmds/down.sh` |
| **Run all local dev tasks** | Starts the cluster, waits 5s, then starts the SPA client watcher |
| **Run Client Watch** | Runs `npm run watch` in the `spa` container for live client rebuilds |
| **View Logs** | Prompts for a service name and tails its logs |
| **Restart Service** | Prompts for a service name and restarts it |
| **Open Shell** | Prompts for a service name and opens a bash shell in that container |
