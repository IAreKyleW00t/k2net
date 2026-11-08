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

System configurations are managed via [Ansible](https://www.ansible.com/) for bare-metal operations. Updates to [`ansible/`](ansible/) are deployed manually.

The pinned collections require `ansible-core` 2.19 or later. Use the [Ansible support matrix](https://docs.ansible.com/projects/ansible/latest/reference_appendices/release_and_maintenance.html) to select compatible core and controller Python versions. These requirements do not identify a tested controller version. This inventory requires the 1Password CLI (`op`) version 2 or later.

```sh
cd ansible/
ansible-galaxy collection install -r requirements.yaml
ansible-inventory -i inventory/hosts.ini --graph
```

The inventory lists hosts and their groups in `inventory/hosts.ini`; shared settings live in `inventory/group_vars/`.

Pi-hole local DNS records and CNAME aliases can be configured in `ansible/inventory/group_vars/pihole.yaml`:

```yaml
pihole_custom_dns_records:
  - 192.168.40.4 unifi.kyle2.net
pihole_custom_cname_records:
  - controller.kyle2.net,unifi.kyle2.net
  # Optional TTL in seconds: alias.example.net,target.example.net,300
```

CNAME targets must be known locally to Pi-hole. Ansible manages the complete local DNS and CNAME record lists through environment variables. Empty inventory lists clear the corresponding lists in Pi-hole. Before you run the role, copy any UI-managed records that you want to keep into inventory. Pi-hole makes these settings read-only in its web interface. Container recreation may briefly interrupt DNS.

Pi-hole expects NetworkManager to manage the default interface and host DNS. Docker can route traffic to Pi-hole's published ports before ordinary UFW input rules apply. The role does not restrict client source addresses. Public access depends on the host and network configuration.

Optional Pi-hole custom dnsmasq directives use `pihole_custom_dnsmasq_lines`, which defaults to `[]`.
When the list is empty, Ansible omits `FTLCONF_misc_dnsmasq_lines` from the container environment.
Leaving this input unused does not adopt or clear an existing persistent custom-lines setting.
When nonempty, entries are joined with semicolons in their configured order.
Use one directive per entry. Do not embed semicolons; Pi-hole uses them as array separators.
This setting does not require enabling `/etc/dnsmasq.d` or editing `pihole.toml`.

The list replaces the complete custom-lines value; it does not merge with existing Pi-hole settings.
Before using it, copy any existing custom lines that you want to keep into inventory.
Environment-managed settings override persistent values and cannot be changed through the web interface or CLI.
If a previously configured list becomes empty, Ansible removes the environment override during container reconciliation.
Pi-hole then resets that setting to its default `[]`; it does not restore the older custom lines.
Adding, changing, or removing the environment override can recreate the container and briefly interrupt DNS.
Invalid or conflicting directives can stop DNS resolution. Existing local DNS and CNAME inputs remain separate and unchanged.

The Pi-hole inventory configures the following internal wildcard DNS mapping:

```yaml
pihole_custom_dnsmasq_lines:
  - address=/*.home.kyle2.net/192.168.40.6
```

This rule matches subdomains, including deeper names, but excludes `home.kyle2.net` itself.
A TLS certificate for `*.home.kyle2.net` covers only one hostname label, not deeper names.
With dnsmasq 2.86 or later, the IPv4-only rule forwards TXT and AAAA queries upstream.
Public AAAA answers can therefore direct IPv6 clients elsewhere. Confirm that behavior before enabling the rule.
Do not add a broad `local=` rule merely to suppress AAAA.
It also prevents upstream TXT lookups used by ACME propagation checks.
Public authoritative DNS must still serve the DNS-01 challenge TXT records.

See the official [Docker configuration](https://docs.pi-hole.net/docker/configuration/),
[FTL custom-lines setting](https://docs.pi-hole.net/ftldns/configfile/#dnsmasq_lines),
[v6 migration guidance](https://docs.pi-hole.net/docker/upgrading/v5-v6/#custom-dnsmasq-config-files),
and [dnsmasq manual](https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html).

Application roles consume ordinary secret variables and do not depend on a specific secret backend. K2NET inventory may populate those values through the local 1Password CLI and Ansible's `community.general.onepassword` lookup; another deployment may use Vault, SOPS, AWX, or another backend. Workload playbooks are `pihole.yaml`, `wireguard.yaml`, `unifi.yaml`, and `caddy.yaml`.

Each role's `tasks/main.yaml` imports focused task files in execution order. Shared reboot tasks remain in `common/tasks/reboot.yaml` and are invoked by the workload playbooks.

#### Ansible tags
Each workload playbook supports the `common` tag and its application role tag. The Pi-hole, WireGuard, and Caddy playbooks include the `docker` role tag. The roles also support these step tags:

| Role | Step tags |
| --- | --- |
| Common | `common_hostname`, `common_packages`, `common_firewall`, `common_updates`, `common_ssh` |
| Docker | `docker_preflight`, `docker_repository`, `docker_install`, `docker_verify` |
| Pi-hole | `pihole_preflight`, `pihole_directories`, `pihole_dns`, `pihole_firewall`, `pihole_container`, `pihole_verify` |
| WireGuard | `wireguard_preflight`, `wireguard_configure`, `wireguard_firewall`, `wireguard_container`, `wireguard_verify` |
| UniFi | `unifi_preflight`, `unifi_firewall`, `unifi_install`, `unifi_verify`, `unifi_sites` |
| Caddy | `caddy_preflight`, `caddy_firewall`, `caddy_configure`, `caddy_container`, `caddy_verify` |

From `ansible/`, for example:

```sh
ansible-playbook -i inventory/hosts.ini pihole.yaml --tags pihole
ansible-playbook -i inventory/hosts.ini unifi.yaml --tags unifi_sites
ansible-playbook -i inventory/hosts.ini wireguard.yaml --tags wireguard_configure,wireguard_container --limit <host>
ansible-playbook -i inventory/hosts.ini pihole.yaml --list-tags
```

Run the complete workload playbook without tags for the initial installation. A role tag selects that role, not its prerequisite roles. Step tags include the fact gathering and validation needed by that step, but do not install or configure its dependencies. Notified handlers can still restart or reload services during tagged runs.

Docker installation requires the Docker repository. Firewall and update steps require their packages. Container steps require Docker, persistent directories, and configuration. UniFi site deployment requires an existing UniFi installation.

The `common_reboot` tag selects the conditional reboot post-task explicitly. Untagged runs retain their normal reboot behavior; selecting `common` or another step tag alone does not select the reboot.

Place static UniFi Network site files under `ansible/files/unifi/sites/<site-id>/`, for example `default/config.gateway.json`. The role copies them into the corresponding site directory in the UniFi OS Server Podman volume. It preserves unrelated files but replaces each complete destination file.

Before you run the role, add any required destination settings to the source file. Check the IoT interface and NAT rule ID. After you copy `config.gateway.json`, provision the USG manually. The role does not restart UniFi OS Server or provision the gateway.

Ansible uses the installer URL only when UniFi OS Server is absent. Use [UniFi](https://help.ui.com/hc/en-us/articles/7605005245975-UniFi-Updates) to update an existing installation. The USG is a [Legacy product](https://help.ui.com/hc/en-us/articles/1500001268521-Ubiquiti-s-Vintage-and-Legacy-Products). Before you update UniFi, review compatibility with the USG and its custom configuration.

Workload playbooks reboot hosts when `/var/run/reboot-required` exists, after configuration and handlers complete. Reboots interrupt services and run one host at a time. Check mode reports a pending reboot without performing it. Unattended security updates do not reboot hosts automatically. Ansible waits for the host to reconnect after a reboot, but does not verify application readiness.

WGPortal stores interface and peer settings in its database. Inventory port and subnet values set defaults for new interfaces. Ansible also uses these values for firewall rules. Changing these inventory values does not update existing interfaces. Coordinate changes to existing interfaces with the matching firewall rules. The role configures IPv4 host routing only.

Preserve the WGPortal database and its encryption passphrase. Treat configuration exports as secret files. These exports do not replace the database. WGPortal uses the administrator password only when it creates the account. Change an existing password in WGPortal. Update the secret store separately.

When you narrow the WGPortal web allowlist, remove the old UFW rule separately.

#### Caddy

The `caddy` role runs on Morganite through `caddy.yaml`. Its default image is the published
[Caddy Cloudflare image](https://github.com/IAreKyleW00t/docker-caddy-cloudflare).
It does not build images or configure Pi-hole.

Before deployment, supply these inputs in `ansible/inventory/group_vars/caddy.yaml`:

- `caddy_container_image`: optional override for any image with the Cloudflare DNS module; defaults to `iarekylew00t/caddy-cloudflare:latest`.
- `caddy_acme_email`: the approved ACME contact.
- `caddy_cloudflare_api_token`: the approved 1Password lookup or another secret input.

The ACME contact and token defaults are empty. The role rejects deployment until all required inputs are supplied.
Select an updated image release before deployment. Verify its signature and review its SBOM and security findings.
For a digest override, use the multiarchitecture index digest so Docker can select Morganite's architecture.
The role uses `pull: missing`; an existing local `latest` image is not refreshed on every run.
Override the default with a pinned version or digest in inventory when required.

Restrict the Cloudflare token to `kyle2.net` with Zone DNS Edit and Zone Read permissions.
Secret-bearing tasks suppress Ansible output. Docker administrators can still inspect the container environment.
Do not dump Caddy's environment or share unreviewed container logs.

Caddy publishes TCP 80 and 443 only on `caddy_bind_address`.
The role allows inbound TCP traffic to those ports and that address through UFW.
Its administration API listens on `127.0.0.1:2019` inside the container and is not published.
Docker-published ports can bypass ordinary UFW input rules. Binding a host address is not a client allowlist.
Approve VLAN and WireGuard access before deployment. Do not add WAN forwarding.

For firewall-only updates, select `--tags caddy_firewall --limit morganite` from the Caddy workload playbook.
This step requires installed UFW and runs the same configuration and secret checks as other Caddy deployment steps.

The main Caddyfile requests one Let's Encrypt certificate for `*.home.kyle2.net` through DNS-01.
It returns 404 for unknown covered names and reuses the wildcard certificate for covered application hostnames.
Define routes with the `caddy_sites` hostname-to-upstream mapping in `ansible/inventory/group_vars/caddy.yaml`.
The default `{}` adds no application routes. Use explicit upstream URLs to select HTTP or HTTPS.

Example only; replace the documentation addresses before enabling these routes:

```yaml
caddy_sites:
  app.home.kyle2.net: "http://192.0.2.10:8080"
  secure.home.kyle2.net: "https://192.0.2.20:8443"
```

Use single-label application names under `home.kyle2.net` to reuse the wildcard certificate.
Confirm backend settings before adding each route.
Every `https://` upstream uses TLS with backend certificate verification disabled.
Client-facing HTTPS certificate validation remains unchanged.

Ansible renders all routes into `/srv/docker/caddy/Caddyfile`.
Adding, changing, or removing a mapping entry updates that file and notifies a graceful reload.
Separate service files are no longer imported. Old deployed `sites/` files remain on disk but are ignored.

The configuration directory is mounted read-only at `/etc/caddy`.
Separate writable mounts preserve `/data` and `/config` across container recreation.
Startup and reload explicitly use `/etc/caddy/Caddyfile` with the `caddyfile` adapter.
Configuration changes notify handlers that validate inside the running container, then reload Caddy gracefully.
Configuration-only updates do not restart the container. Initial startup uses Caddy's native configuration loading.

Validation or reload failure stops the run. There are no backups, staging trees, or automatic recovery tasks.
Files remain on disk, while a rejected reload leaves the running configuration unchanged.
Correct or revert the source configuration and redeploy. A bad file can prevent the next container startup.
An unchanged rerun does not notify the handlers; explicitly validate and reload if needed after troubleshooting.
Validation output is suppressed because provider errors can contain credentials. Review diagnostics locally before sharing them.
Do not delete `data` or `config` when correcting configuration.
The data directory contains certificate private keys and ACME account state. Back it up as secret material.

For configuration-only updates, select `--tags caddy_configure --limit morganite` from the Caddy workload playbook.
This selection does not run common, Docker, WireGuard, or firewall tasks.
It also skips the conditional reboot post-task.
Image, environment, port, or mount changes can still replace the Caddy container.
The full workload retains prerequisite role ordering and conditional reboot behavior. Schedule it as VPN-host maintenance.
TCP readiness and configuration validation do not establish certificate issuance or backend operation.

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
