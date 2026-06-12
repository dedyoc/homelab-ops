# homelab-ops — GitOps manifests

This repo is the desired state of the k3s cluster, reconciled by ArgoCD. It contains
ONLY manifests/Helm/Kustomize: operators (Strimzi, Altinity ClickHouse, Flink),
their CRs (KafkaCluster, ClickHouseInstallation, FlinkDeployment), Dagster, MinIO,
schema registry, Prometheus stack, Grafana, and ArgoCD Applications. Pipeline code
lives in `bluesky-trends` — never write Python/application logic here.

## Always-true rules
- GitOps is absolute: changes land by commit; ArgoCD syncs. Never run or suggest
  `kubectl apply/delete/edit` or `helm install/upgrade` against the cluster.
  Read-only kubectl (get/describe/logs) is fine for diagnosis.
- NEVER write a plaintext secret, token, or password into any file. Secrets use
  SealedSecrets only. Treat any `stringData:`
  with a literal value as a blocking error.
- Every workload sets resources.requests AND limits — homelab nodes are small.
- Stateful sets (Kafka, ClickHouse, MinIO) pin to local-NVMe storage class
  topolvm with node affinity; stateless stays unpinned.
- Validate before claiming done: `kubeconform -strict` (with CRD schemas) and
  `helm lint` / `kustomize build` for the changed app.
- Image tags are pinned (no :latest). Tag bumps arrive via ArgoCD Image Updater
  commits or explicit PRs from bluesky-trends CI.
- When I correct a mistake, append it to @.claude/memory/defects.md.

## Imported context
- Cluster topology & app conventions: @.claude/memory/cluster.md
- Known defects: @.claude/memory/defects.md

## Workflow
- Session start: read @_state.md; end: update it.
- Plan mode for anything touching an operator CR or more than one app.
- Diffs reviewed by the `manifest-reviewer` subagent before commit.
