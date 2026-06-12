# Cluster & repo conventions — homelab-ops

> Replace placeholders. This is the file Claude reads to know "where things go".

## Cluster
- k3s <REPLACE: version>, nodes: <REPLACE: count, CPU/RAM, which have NVMe>.
- Storage classes: <REPLACE: local NVMe class> (stateful), <REPLACE: default> (rest).
- Ingress: <REPLACE: traefik (k3s default) | nginx>; LB: <REPLACE: klipper | metallb>.
- ArgoCD <REPLACE: version>, app-of-apps rooted at `apps/root.yaml`. Sync policy:
  <REPLACE: automated+selfHeal? prune?>.

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
- ClickHouse schema migrations: versioned SQL in `platform/clickhouse/migrations/`,
  applied by <REPLACE: job/init mechanism> — never by hand.
- Grafana dashboards live in git as JSON (provisioned), not edited in the UI.
- Prometheus alerts that must exist: consumer lag, ingest last_event_ts staleness,
  Flink checkpoint age, ClickHouse parts count, ArgoCD app OutOfSync>15m, node disk.

## Image flow
bluesky-trends CI -> registry <REPLACE> -> ArgoCD Image Updater (annotations on the
Application) -> git commit here -> ArgoCD sync. Manual tag bumps via PR are also OK.
