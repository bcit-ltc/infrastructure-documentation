---
hide:
  - toc
---
# Development workflow

Whether it's a small interaction for an single course, or a larger, more complicated application for an entire program, we develop and operate *containerized apps* that can be deployed on Kubernetes.

!!! tip "Development Strategy"

    Rather than building every functional component into one large monolith, the approach is to build smaller apps that have one purpose, and then connect them together in a microservice architecture.
    
    This makes it easier to update a specific component without having to change to something that already works well.

Our infrastructure makes it easy to adopt a modern, automated, development workflow:

- [x] local development using [`docker compose`](https://docs.docker.com/compose/install/)
- [x] centralized version control, image registries, and automated deployment using [GitLab](https://gitlab.com)
- [x] a progressive release strategy using `review`, `latest`, and `stable` environments
- [x] `base` and `overlay` release packaging using [Kustomize](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)
- [x] continuous deployment using [FluxCD](https://fluxcd.io/flux/)
- [x] secrets management using [Hashicorp Vault](https://www.vaultproject.io/docs)
- [x] automatic semantic versioning using [semantic-release](https://semantic-release.gitbook.io/semantic-release/)

## Workflow Overview

![Deployment Pipeline](../assets/deploy-pipeline-overview-light.png#only-light)
![Deployment Pipeline](../assets/deploy-pipeline-overview-dark.png#only-dark)

1. Create an Issue, a Merge Request (MR), and new branch for development

1. Checkout the new branch, develop, commit, and push

1. Push your code to trigger a pipeline that builds an image and pushes the image to the project registry

1. The pipeline deploys the deployment to a cluster for **`review`**

1. Use `docker compose` to develop app functionality locally.

1. Each push to the branch triggers an additional pipeline. View your changes by clicking the **View App** button in the merge request.
