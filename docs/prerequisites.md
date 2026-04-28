# Prerequisites

All deployment workflows require the following tools. Install them before proceeding.

## Required Tools

### cork-kube

UCD Library's build and deployment CLI. Used to build images via Google Cloud Build, manage Kubernetes deployments, and sync secrets from GCP Secret Manager.

```bash
npm install -g @ucd-lib/cork-kube
```

Source and documentation: https://github.com/ucd-library/cork-kube

### gcloud CLI

Google Cloud SDK. Required for authenticating to GCP, pulling secrets, and (for image builds) submitting Cloud Build jobs.

Install: https://cloud.google.com/sdk/docs/install

After installing, `cork-kube` handles gcloud authentication per environment via `cork-kube init <env>`.

### kubectl

Kubernetes CLI. Required for the dev cluster workflow.

Install: https://kubernetes.io/docs/tasks/tools/

`cork-kube` configures the kubectl context automatically when you activate an environment.

## GCP Access

Both the dev cluster and build workflows require access to the `aggie-experts` GCP project. Access to GCP Secret Manager secrets is required for:

- Pulling the dev kubeconfig
- Syncing k8s secrets (postgres password, OIDC client secret, TLS cert, etc.)
- Fetching the service account JSON for local dev

If you do not have access, contact the project lead.

## Access by Environment

| Environment | Access Required |
|---|---|
| Local development | GCP project `aggie-experts` (Secret Manager read) |
| Dev cluster | GCP project `aggie-experts` (Secret Manager read, kubeconfig secret) |
| Production | SSH access to `experts-anduin.library.ucdavis.edu` + credentials from project lead |
