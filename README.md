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
