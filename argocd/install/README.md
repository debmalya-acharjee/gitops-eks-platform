# ArgoCD Bootstrap

ArgoCD itself is installed via its official manifest rather than Terraform —
this is intentional and matches common real-world practice (cluster infra via
Terraform, cluster *workloads* via GitOps tooling installed directly).

## Install steps

```bash
kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get the initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port-forward to access the UI locally
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Then open https://localhost:8080 (user: admin)
```

## Register your app

Once ArgoCD is running, apply the Application manifest in `../apps/sample-app-application.yaml`
to tell ArgoCD to sync `apps/sample-api/k8s/` from your GitHub repo automatically.

This is the core GitOps loop you're demonstrating: git push → ArgoCD detects
drift → ArgoCD reconciles cluster state to match Git, with no manual `kubectl apply`.
