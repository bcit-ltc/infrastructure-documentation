# LTC Infrastructure Documentation

Information about the architecture and makeup of the LTC's server infrastructure.

## Developing

1. Create an issue and a merge request
1. Checkout the branch in your code editor
1. Open a terminal and run

    docker compose up

1. Browse to `http://localhost:8000` to see site with *live reload* enabled.

## Building

1. Create an issue and a merge request
1. Checkout the branch in your code editor
1. Commit and push to the repo. The CI/CD pipeline will build and push the image to the cluster specified in the `.gitlab-ci.yml` file.

## Cleanup

To remove pods stuck in `Terminating`, run the following:

    kubectl get pods --all-namespaces | grep Terminating | while read namespace pod rest; do kubectl delete pod $pod -n $namespace --force; done

## Testing

    curl http://registry.local:5000/v2/_catalog
    skaffold dev -f .devcontainer/skaffold/skaffold.yaml --default-repo registry.localhost:5000
    kubectl -n kubernetes-dashboard create token kubernetes-dashboard-web
    kubectl get events
    kubectl port-forward pods/infrastructure-documentation-deployment-f6fcf89d5-lrgvb 8080:80
    kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
    kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d

          # {{- with .Values.resources }}
          # resources:
          #   {{- toYaml . | nindent 12 }}
          # {{- end }}

    kubectl -n NAMESPACE create token SERVICE_ACCOUNT
    kubectl patch svc nginx --type='json' -p='[{"op": "replace", "path": "/spec/ports/0/port", "value":"8080"}]'
    skaffold config set kind-disable-load true
    skaffold config set default-repo localhost:5000
    skaffold config set insecure-registries http://localhost:5000
    # CMD ["serve", "--dev-addr=0.0.0.0:8000", "-a", "0.0.0.0:8080"]
