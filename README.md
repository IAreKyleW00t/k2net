# 🧪 K2NET [![status](https://img.shields.io/badge/Status-2ea043)](https://status.kyle2.net/)

My homelab, managed with GitOps using [Terraform](https://www.terraform.io/), [Ansible](https://www.ansible.com/), and [ArgoCD](https://argoproj.github.io/cd/) on my [k3s](https://k3s.io/) cluster.

Dependency updates are handled via [Renovate](https://github.com/renovatebot/renovate) with it's respective [configuration](.github/renovate.json).

[![Repobeats](https://repobeats.axiom.co/api/embed/7c6b1531114f03fd7eeb3b3a7d089e9ea7e9949d.svg)](#)

## Preparation

### Local tools

The following tools are required to be installed locally for all sections to function properly.

- `kubectl`
- `helm`
- `ansible`
- `terraform` (Optional)
- `jq`
- `yq`

### Terraform

All **cloud** resources are configured via [Terraform](https://www.terraform.io/) with their respective states stored in [Terraform Cloud](https://app.terraform.io/session). Changes to the [`terraform/`](terraform/) directory will be detected and deployed automatically via the [Terraform workflow](.github/workflows/terraform.yaml).

### Ansible

System configurations are managed via [Ansible](https://www.ansible.com/) and is used for any "bare metal" operations (including setting up the k3s cluster itself). There is no form of automatic deployment for files in the [`ansible/`](ansible/) directory; any updates will need to be deployed manually.

```sh
cd ansible/
ansible-playbook --vault-password-file ansible_vault.key -i inventory all.yaml
```

### k3s

#### 1Password

Secrets are managed via [1Password](https://1password.com/) using the [1Password Connect Kubernetes Operator](https://github.com/1Password/onepassword-operator). Since other applications make use of this, we must install it manually the first time.

Create the Namespace for 1Password Connect Operator.

```sh
kubectl create namespace op-connect
```

Create the Secrets containing your `1password-credentials.json` and token (we Base64 encode the file because it's passed to 1Password through environment variables and gets decoded by the Operator)

```sh
kubectl create -n op-connect secret generic onepassword-token --from-literal=token=<your token here>
kubectl create -n op-connect secret generic op-credentials --from-literal=1password-credentials.json=$(base64 -w0 1password-credentials.json)
```

Install the 1Password Connect Operator.

```sh
helm repo add 1password https://1password.github.io/connect-helm-charts
helm repo update
OP_VERSION=$(cat k8s/deploy/op-connect/Chart.yaml | yq -r '.dependencies[0].version')
helm upgrade --install op-connect 1password/connect \
    --version "$OP_VERSION" \
    --set operator.create=true \
    --namespace op-connect \
    --create-namespace \
    --atomic
```

#### ArgoCD

Everything is deployed through [ArgoCD](https://argoproj.github.io/cd/), including ArgoCD itself. However, we must manually deploy it the first time before it can start to track it's own changes.
Because of how the ArgoCD Helm Chart is setup, it is not possible to inject the `admin` password during setup.

```sh
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
ARGO_VERSION=$(cat k8s/deploy/argocd/Chart.yaml | yq -r '.dependencies[0].version')
helm upgrade --install argocd argo/argo-cd \
    --version "$ARGO_VERSION" \
    --namespace argocd \
    --create-namespace \
    --atomic
```

Get the default random `admin` password:

```sh
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

#### Applications

There are a few secrets and data that needs to be configured _before_ deploying any applications. These secrets are included via `OnePasswordItem` CR's in the [`k8s/prep`](k8s/prep/) folder.

```sh
for dir in k8s/prep/*; do
  kubectl apply -f "$dir"
done
```

## Deployments

Each application is listed in the [`k8s/apps`](k8s/apps/) folder, including "system" apps. Applications are deployed through ArgoCD and will track changes through it once initially configured. The deployments themselves are all stored in the [`k8s/deploy`](k8s/deploy/) folder and future changes are automatically picked up via ArgoCD.

```sh
kubectl apply -f k8s/apps/<app>.yaml
```

When initially setting up the Cluster, the order of how each component is deployed will matter since some componentes depend on one another.

```sh
# Core components
kubectl apply -f k8s/apps/op-connect.yaml
kubectl apply -f k8s/apps/metallb.yaml
kubectl apply -f k8s/apps/cert-manager.yaml
kubectl apply -f k8s/apps/external-dns.yaml
kubectl apply -f k8s/apps/ingress-nginx.yaml
kubectl apply -f k8s/apps/linkerd.yaml

# Storage
kubectl apply -f k8s/apps/snapshot-controller.yaml
kubectl apply -f k8s/apps/synology-csi.yaml
kubectl apply -f k8s/apps/longhorn.yaml
kubectl apply -f k8s/apps/nfs-subdir-external-provisioner.yaml

# System applications
kubectl apply -f k8s/apps/grafana.yaml
kubectl apply -f k8s/apps/loki.yaml
kubectl apply -f k8s/apps/promtail.yaml
kubectl apply -f k8s/apps/policy-controller.yaml
kubectl apply -f k8s/apps/node-problem-detector.yaml
kubectl apply -f k8s/apps/metrics-server.yaml
kubectl apply -f k8s/apps/descheduler.yaml
kubectl apply -f k8s/apps/argocd.yaml

# User applications
kubectl apply -f k8s/apps/bitwarden.yaml
kubectl apply -f k8s/apps/heimdall.yaml
kubectl apply -f k8s/apps/home-assistant.yaml
kubectl apply -f k8s/apps/mqtt.yaml
kubectl apply -f k8s/apps/starr-system.yaml
kubectl apply -f k8s/apps/thelounge.yaml
kubectl apply -f k8s/apps/unifi.yaml
kubectl apply -f k8s/apps/uptime-kuma.yaml
```

## Contributing

Feel free to contribute and make things better by opening an [Issue](https://github.com/IAreKyleW00t/k2net/issues) or [Pull Request](https://github.com/IAreKyleW00t/k2net/pulls).

## License

See [LICENSE](LICENSE).
