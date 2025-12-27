set shell := ["bash", "-c"]

# --- 1. QUICK STATUS ---

# Default: Show system health and resource usage
default:
    @echo "=== Local Cloud Status ==="
    @just resources
    @echo ""
    @echo "=== Recipes ==="
    @just --list

# Check Memory/CPU pressure (Critical for our 32GB Limit)
resources:
    @echo "--- Node Usage ---"
    kubectl top node
    @echo ""
    @echo "--- Namespace Quotas (Data-Ops Limit: 16GB) ---"
    kubectl get resourcequota -A --no-headers | awk '{printf "%-15s %-20s %s\n", $1, $2, $3}'

# Check Storage Usage (Tier 1 vs Tier 2)
storage:
    @echo "--- NVMe Tier 1 (Scratch/Swap) ---"
    df -h /mnt/scratch | grep -v Filesystem
    @echo "--- NVMe Tier 2 (Bulk/OS) ---"
    df -h /var/lib/rancher | grep -v Filesystem
    @echo "--- Swap Usage (Safety Net) ---"
    swapon --show

# --- 2. GITOPS CONTROLS ---

# Force ArgoCD to sync the System Layer (Apply infra changes immediately)
sync-sys:
    kubectl patch application system-layer -n argocd --type merge -p '{"spec": {"syncPolicy": {"automated": {"prune": true, "selfHeal": true}}}}'
    @echo "Triggered sync for system-layer..."

# Force sync a specific app (Usage: just sync-app actual-budget)
sync-app APP:
    kubectl patch application {{APP}} -n argocd --type merge -p '{"operation": {"sync": {"prune": true}}}'

# --- 3. DEBUGGING & CLEANUP ---

# Tail logs for a specific app (Usage: just logs home-ops jellyfin)
logs NS APP_LABEL:
    kubectl logs -n {{NS}} -l app={{APP_LABEL}} -f --tail=50

# Watch events to debug scheduling/OOM issues
watch-events:
    kubectl get events -A --sort-by='.lastTimestamp' -w

# Cleanup: Delete all Evicted/Failed pods (Frees up IP addresses)
clean-garbage:
    kubectl delete pods --field-selector status.phase=Failed -A
    kubectl delete pods --field-selector status.phase=Succeeded -A

# --- 4. NETWORKING ---

# Check Tailscale Status & IPs
net-status:
    tailscale status
    @echo ""
    @echo "--- Ingress Routes ---"
    kubectl get ingress -A
