# Cluster & repo conventions — homelab-ops

> Replace placeholders. This is the file Claude reads to know "where things go".

## Cluster
- k3s v1.34, nodes: 1 single node (8 cores / 16 threads, 32GB RAM, local NVMe).
- Storage classes: topolvm (stateful), local-path (rest, default).
- Ingress: Tailscale operator (tailscale IngressClass); LB + TLS handled by Tailscale.
- ArgoCD v3.3.4, app-of-apps rooted at `apps/root.yaml`. Sync policy:
  - Root + stateless apps: automated, selfHeal=true, prune=true.
  - Stateful apps (Kafka, ClickHouse, MinIO): automated, selfHeal=true, prune=false;
    Prune=false annotation on PVCs/StatefulSets, PruneLast.
  - Cluster-wide syncOptions: ServerSideApply=true, CreateNamespace=true.
  - Add ignoreDifferences per operator as sync loops appear.

## Repo layout
```
apps/                  # ArgoCD Application CRs (one per app, app-of-apps root)
infra/                 # operators: strimzi/, altinity-clickhouse/, flink-operator/,
                       # minio/, schema-registry/, monitoring/ (kube-prometheus-stack)
platform/              # our CRs + configs: kafka/ (KafkaCluster, topics, users),
                       # clickhouse/ (CHI, schemas as configmaps), flink/ (FlinkDeployment),
                       # dagster/, grafana/ (dashboards as code), trends-api/
secrets/               # sealed/encrypted only
```

## Conventions
- One namespace per concern: `kafka`, `clickhouse`, `flink`, `dagster`, `monitoring`,
  `minio`, `apps`. ArgoCD Applications mirror these.
- Kafka topics are declared as Strimzi KafkaTopic CRs (partitions, retention) — never
  auto-created by clients.
- FlinkDeployment: checkpoints/savepoints -> MinIO bucket `flink-checkpoints/`;
  upgradeMode: savepoint for stateful changes.
- ClickHouse schema migrations: versioned SQL in `platform/clickhouse/migrations/`.
  Foundational schema (raw tables, Kafka engine, MVs) applied by a migration tool with
  a `schema_migrations` table, run as an ArgoCD PreSync hook Job
  (hook-delete-policy HookSucceeded, pinned image) — never by hand. MV changes are
  drop-and-recreate steps. dbt owns the marts — keep them separate.
- Grafana dashboards live in git as JSON (provisioned), not edited in the UI.
- Prometheus alerts that must exist: consumer lag, ingest last_event_ts staleness,
  Flink checkpoint age, ClickHouse parts count, ArgoCD app OutOfSync>15m, node disk.

## Image flow
bluesky-trends CI -> registry ghcr.io -> ArgoCD Image Updater (annotations on the
Application) -> git commit here -> ArgoCD sync. Manual tag bumps via PR are also OK.
