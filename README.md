# aggie-experts-deployment

GitOps repository for deploying [Aggie Experts](https://github.com/ucd-library/aggie-experts) — the UC Davis faculty expertise discovery platform. Manages two environments:

| Environment | Platform | Host |
|---|---|---|
| **dev** | Kubernetes (microk8s) via Kustomize | `libk8s` cluster, `aggie-experts-dev` namespace |
| **prod** | Docker Compose | `experts-anduin.library.ucdavis.edu` |

A local development environment (Docker Compose with source mounts) is also supported for active development.

## Services

| Service | Description |
|---|---|
| `anduin-gateway` | Keycloak OIDC auth gateway — entry point for Dagster, CaskFS, Superset, and Kibana |
| `dagster-ui` | Dagster workflow orchestration UI |
| `dagster-daemon` | Dagster background scheduler |
| `dagster-celery-worker` | Celery workers that execute harvest ETL jobs |
| `caskfs-ui` | CaskFS content-addressed artifact store UI |
| `superset` | Apache Superset ETL dashboards |
| `webapp-gateway` | Express gateway for the public-facing webapp |
| `spa` | Lit web component single-page application |
| `api` | REST API for expert, work, and grant data |
| `postgres` | PostgreSQL — application data, Dagster metadata, Superset reporting |
| `elasticsearch` | Elasticsearch — expert, work, and grant search indexes |
| `kibana` | Kibana — Elasticsearch exploration UI |
| `rabbitmq` | RabbitMQ — Celery task queue |

## Documentation

- [Prerequisites](docs/prerequisites.md) — required tools and access
- [Local Development](docs/local-dev.md) — run the full stack locally with source mounts
- [Dev Cluster (Kubernetes)](docs/dev-cluster.md) — deploy and manage the `aggie-experts-dev` namespace on the `libk8s` microk8s cluster
- [Production (Docker Compose)](docs/prod-cluster.md) — deploy and manage the production server
- [Updating Deployments](docs/updating-deployments.md) — build new images and roll them out to dev or prod

## Related Repositories

- [aggie-experts](https://github.com/ucd-library/aggie-experts) — application source code
- [project-anduin](https://github.com/ucd-library/project-anduin) — ETL platform (auth gateway, Superset)
- [caskfs](https://github.com/ucd-library/caskfs) — content-addressed artifact store
- [cork-kube](https://github.com/ucd-library/cork-kube) — build and deployment CLI
- [cork-build-registry](https://github.com/ucd-library/cork-build-registry) — versioned image dependency definitions
