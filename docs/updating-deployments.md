# Updating Deployments

The release workflow is: build images → update this repo → apply to dev → validate → apply to prod.

## 1. Build Images

Available build versions and their dependency pins (CaskFS, project-anduin, Postgres) are defined in the [cork-build-registry](https://github.com/ucd-library/cork-build-registry).

Tag a release in the application repo and trigger a Cloud Build:

```bash
# in the aggie-experts repo
git tag 5.1.0
git push origin 5.1.0

# trigger the build
cork-kube build gcb -p aggie-experts -v 5.1.0
```

This publishes versioned images to Google Artifact Registry:

```
us-west1-docker.pkg.dev/aggie-experts/pub/harvest:<version>
us-west1-docker.pkg.dev/aggie-experts/pub/webapp:<version>
us-west1-docker.pkg.dev/aggie-experts/pub/ae-postgres:<version>
us-west1-docker.pkg.dev/aggie-experts/pub/elastic-search:<version>
us-west1-docker.pkg.dev/aggie-experts/pub/anduin-gateway:<version>
```

## 2. Update the Deployment Repo

`update-deployment.sh` resolves dependency versions from the cork-build-registry, patches image tags in the appropriate kustomize overlays or compose file, and commits and pushes the changes.

```bash
# update dev kustomize overlays
./cmds/update-deployment.sh dev 5.1.0

# update prod compose file
./cmds/update-deployment.sh prod 5.1.0
```

Both commands will prompt to commit and push the changes to this repo.

## 3. Apply to Dev (Kubernetes)

After the dev overlays are updated and pushed:

```bash
cork-kube init dev     # ensure gcloud/kubectl are configured
cork-kube up dev       # apply updated image tags to the cluster
```

To roll out only a specific service group:

```bash
cork-kube up dev -g webapp
cork-kube up dev -g anduin
```

Validate the deployment at https://anduin-dev.experts.library.ucdavis.edu before proceeding to prod.

## 4. Apply to Production (Docker Compose)

After validating dev and after the prod compose file has been updated and pushed:

```bash
ssh experts-anduin.library.ucdavis.edu
cd /opt/aggie-experts-deployment/compose/prod

./update-cluster.sh webapp    # zero-downtime; restarts webapp-gateway, spa, api
./update-cluster.sh anduin    # restarts ETL stack; brief harvest interruption
./update-cluster.sh all       # full restart; only if postgres/elasticsearch need to restart
```

`update-cluster.sh` runs `git pull` and `docker compose pull` automatically before restarting.

## Deployment Order

Always update dev first, validate, then update prod:

```
update-deployment.sh dev 5.1.0  →  cork-kube up dev  →  validate
update-deployment.sh prod 5.1.0  →  ssh + update-cluster.sh
```

Commit messages in this repo follow the pattern:
```
Updated prod to version 5.1.0 (CaskFS: 0.1.1, Anduin: 0.1.2, Postgres: 16)
```
