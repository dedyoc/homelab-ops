# Homelab Ops

Central repository for managing a k3s-based home laboratory using GitOps principles and platform engineering abstractions.

## Project Overview

This project automates the deployment and management of infrastructure and applications on a private Kubernetes cluster. It leverages ArgoCD for continuous delivery, following the "App-of-Apps" and "ApplicationSet" patterns.

### Main Technologies
- **Kubernetes (k3s):** Target runtime environment.
- **ArgoCD:** GitOps controller for application lifecycle management.
- **Kustomize:** Configuration management for infrastructure modules.
- **Tailscale:** Secure networking and proxying.
- **Sealed Secrets:** Kubernetes-native secret encryption.
- **Dagster:** Data orchestration (integrated via `platform-sdk`).
- **Python:** Custom platform engineering tooling.

## Architecture

### 1. GitOps Control Plane (`argocd/`)
The cluster configuration is driven by the manifests in this directory.
- **`applications/`**: Contains standalone ArgoCD `Application` manifests for tenant workloads (e.g., `bluesky-trends`).
- **`applicationsets/`**: Automation for bulk deployments.
    - `infra-appset.yaml`: Dynamically generates applications for every module in `infrastructure/`.
    - `tenant-apps.yaml`: A master application that synchronizes the `applications/` directory.

### 2. Infrastructure Modules (`infrastructure/`)
Standardized components deployed to the cluster. Each subdirectory is a Kustomize-ready module.
- `argocd-tailscale-proxy`: Exposes the ArgoCD UI over Tailscale.
- `sealed-secrets`: The Bitnami Sealed Secrets controller for managing encrypted secrets.
- `tailscale-operator`: Enables seamless integration between K8s services and Tailscale.

### 3. Platform SDK (`platform-sdk/`)
A Python package (`homelab-sdk`) that provides abstractions for platform-specific constraints.
- **Location:** `platform-sdk/`
- **Purpose:** Standardizes compute tiers (micro, base, heavy, max) for Dagster pipelines, optimized for 32GB node constraints.

## Building and Running

### Infrastructure Deployment
Changes committed to the `main` branch are automatically synced by ArgoCD. To manually trigger a sync or check status:
```bash
# TODO: Document preferred CLI tools (e.g., argocd cli or kubectl commands)
kubectl get applications -n argocd
```

### Platform SDK Development
The SDK is managed via `setuptools` (defined in `pyproject.toml`).
- **Install for development:**
  ```bash
  pip install -e ./platform-sdk
  ```
- **Dependencies:** `dagster`, `dagster-k8s`.

## Development Conventions

- **Infrastructure Changes:** Always use Kustomize. If using a Helm chart, include it via the `helmCharts` field in `kustomization.yaml` rather than manual templating.
- **Secret Management:** Never commit raw secrets. Use `kubeseal` to create `SealedSecret` resources.
- **Application Onboarding:** To deploy a new app, create a manifest in `argocd/applications/`.
- **Compute Constraints:** When defining resource limits for data pipelines, use the `homelab_sdk.compute` module to ensure adherence to cluster capacity limits.
- **Git Workflow:** Follow a trunk-based development approach. The `main` branch is the source of truth for the cluster state.
