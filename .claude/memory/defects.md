# Defects log — homelab-ops

> Append: [date] what — cause — rule. Pre-loaded entries are known failure modes
> of this stack on small clusters; treat as already-burned lessons.

## Pre-loaded gotchas
- Pod Pending forever — Cause: requests exceed what small homelab nodes can schedule —
  Rule: size requests to reality (check `kubectl describe node` allocatable) before adding workloads.
- Kafka/ClickHouse slow after node reshuffle — Cause: PVs on network/slow storage —
  Rule: stateful pods use local-NVMe storage class + nodeAffinity; verify PV node binding.
- ArgoCD app stuck Progressing — Cause: operator CR status not understood by health check —
  Rule: add custom health checks (resource.customizations) for KafkaCluster/CHI/FlinkDeployment.
- Flink job lost state on upgrade — Cause: upgradeMode stateless / missing operator uids —
  Rule: upgradeMode: savepoint; confirm savepoint completes before merging CR changes.
- Disk filled by ClickHouse/Kafka — Cause: no retention/TTL set —
  Rule: KafkaTopic retention.ms explicit; ClickHouse tables get TTL or tiered move to MinIO.
- Secret leaked in git history — Cause: quick-fix stringData commit —
  Rule: sealed/encrypted secrets only; pre-commit scan; rotating a leaked secret is mandatory.
- Sync loop / constant diff — Cause: mutating webhooks or defaulted fields fighting ArgoCD —
  Rule: add ignoreDifferences for known defaulted fields instead of disabling selfHeal.
- :latest image silently changed behavior — Cause: unpinned tag —
  Rule: pinned tags only; updates flow through Image Updater commits.

## Entries
- (none yet)
