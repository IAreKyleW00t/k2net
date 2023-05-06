# K2NET

My personal Kubernetes cluster, running on [k3s](https://k3s.io/).

🚧 Still under construction! 🚧

## Preparation

### ArgoCD

Everything is deployed through [ArgoCD](https://argoproj.github.io/cd/), including ArgoCD itself. However, we must manually deploy it the first time before it can start to track it's own changes.

```sh
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd argo/argo-cd \
    --atomic \
    --namespace argocd \
    --create-namespace
```

### Application prep

There are a few secrets and data that needs to be configured _before_ deploying
any applications to ensure everything deploys successfully. For completeness, example data
is included in the [`k8s/prep`](k8s/prep/) folder that can be updated with your own.

After changing these files to your needs, you can apply the entire contents of each app directory:

```sh
kubectl apply -f k8s/prep/<app_name>
```

or do it all in one swoop:

```sh
for dir in k8s/prep/*; do
    kubectl apply -f "$dir"
done
```

## App Deployments

Each application is listed in the [`k8s/apps`](k8s/apps/) folder, including "system" apps. Applications are deployed through ArgoCD and will track changes through it once initially configured; changes to the `Application` resource associated with the app in ArgoCD will happen automatically via `git`.

```sh
# For standard k8s manifests
kubectl apply -f k8s/apps/<app_name>/app.yaml

# For Helm charts
kubectl apply -f k8s/apps/<app_name>/templates/app.yaml
```

or deploy them all in one swoop (not recommended):

```sh
for app in $(find k8s/apps/ -type f -name "app.yaml"); do
    kubectl apply -f "$app"
done
```

## Contributing

Feel free to contribute and make things better by opening an [Issue](https://github.com/IAreKyleW00t/k2net/issues) or [Pull Request](https://github.com/IAreKyleW00t/k2net/pulls).

## License

See [LICENSE](LICENSE).
