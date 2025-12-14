# justfile

DATAYOC_USER := "datayoc"
DATAYOC_HOST := "100.99.42.57" # host address on tailnet

ssh:
    ssh {{DATAYOC_USER}}@{{DATAYOC_HOST}}

# Manually forces a full sync of the entire system layer
# Usage: just sync-system
sync-system:
    kubectl patch application system-layer -n argocd --type merge \
        -p '{"spec": {"source": {"targetRevision": "HEAD"}}}'
    echo "System layer sync initiated."

# Forces an ArgoCD application to sync (e.g., just sync-app home-ops)
sync-app APP_NAME:
    kubectl patch application {{APP_NAME}} -n argocd --type merge \
        -p '{"spec": {"source": {"targetRevision": "HEAD"}}}'
    echo "{{APP_NAME}} sync initiated."

# --- troubleshooting ---

# Deletes a pod by name in a specified namespace (e.g., just kill-pod tailscale operator-649...)
kill-pod NAMESPACE POD_NAME:
    kubectl delete pod {{POD_NAME}} -n {{NAMESPACE}}

# Displays logs for a pod (e.g., just logs tailscale operator-649...)
logs NAMESPACE POD_NAME:
    kubectl logs {{POD_NAME}} -n {{NAMESPACE}} -f --tail=50

# Finds all namespaces and resource quotas
q:
    kubectl get ns,quota --all-namespaces
