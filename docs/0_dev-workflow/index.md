---
  title: "Overview"
---
<!-- markdownlint-disable MD025 -->

# Development Workflow Overview

The LTC's infrastructure is designed to make it easy to adopt a modern, automated, development workflow:

- [x] local development using `docker compose`
- [x] centralized version control using GitLab
- [x] private image registries using [GitLab Registry](https://docs.gitlab.com/ee/user/packages/container_registry/)
- [x] modified environments for dev, staging, and production using [Kustomize](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)
- [x] deployment packages managed by [kpt](https://kpt.dev/book/)
- [x] automated deployment using [GitLab Runner CI/CD pipeline](https://docs.gitlab.com/ee/ci/)
- [x] standarized in-cluster image building using [Kaniko](https://github.com/GoogleContainerTools/kaniko)
- [x] secrets management using [Hashicorp Vault](https://www.vaultproject.io/docs)
- [x] git tagged semantic versioning using [semantic-release](https://semantic-release.gitbook.io/semantic-release/)
- [x] packaged release snapshots using [GitLab Releases](https://docs.gitlab.com/ee/user/project/releases/)

The diagram below is an overview of the first steps of a development workflow.

[![Development workflow](../assets/devops-workflow-overview-light.png#only-light)](devops-workflow-overview-large-light.md)
[![Development workflow](../assets/devops-workflow-overview-dark.png#only-dark)](devops-workflow-overview-large-dark.md)

Before anything can happen, make sure you have a code repository! The "Getting Started" page will outline how to add a pipeline to your project, initialize a *deployment package*, and deploy to a Kubernetes cluster.
