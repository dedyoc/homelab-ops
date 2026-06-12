---
name: new-app
description: Onboard a new application or operator into the cluster via GitOps — ArgoCD Application, namespace, manifests/Helm values, secrets references, monitoring. Use whenever adding or restructuring anything ArgoCD deploys.
argument-hint: <app-name>
---

# New app onboarding

Read @.claude/memory/cluster.md for layout and conventions first. Confirm only
what's missing: app name, namespace, Helm chart vs raw manifests, stateful?

## Steps
1. Plan: target namespace, directory under infra/ or platform/, sync wave/order if it
   depends on an operator. Show plan; wait for go-ahead.
2. Create `apps/<name>.yaml` ArgoCD Application: pinned chart/targetRevision, automated
   sync only if safe, finalizer set, project default.
3. Manifests/values:
   - resources.requests/limits on every container (small-node sized).
   - Stateful -> local-NVMe storage class + nodeAffinity + PodDisruptionBudget.
   - Probes (liveness/readiness) defined.
   - Secrets as <sealed/SOPS/external> references only.
4. Monitoring: ServiceMonitor/PodMonitor if the app exposes metrics; add the relevant
   alert rule if it's on the must-exist list in cluster.md.
5. Validate: `kustomize build`/`helm template` renders; `kubeconform -strict` passes
   (with CRD schemas); no plaintext secrets (grep stringData).
6. Update `_state.md`; remind: commit -> ArgoCD syncs; check app health in UI.
