---
  title: "Overview"
---
<!-- markdownlint-disable MD025 -->

# Development Overview

The LTC's infrastructure makes it easy to adopt a modern, automated, development workflow:

- [x] local development using `docker compose`
- [x] centralized version control, image registries, and automated deployment using [GitLab](https://gitlab.com)
- [x] progressive release environments for `dev`, `staging`, and `production` using [Kustomize](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)
- [x] secrets management using [Hashicorp Vault](https://www.vaultproject.io/docs)
- [x] automatic semantic versioning using [semantic-release](https://semantic-release.gitbook.io/semantic-release/)

The diagram below outlines the main components of the development workflow.

[![Development workflow](../assets/devops-workflow-overview-light.png#only-light)](devops-workflow-overview-large-light.md)
[![Development workflow](../assets/devops-workflow-overview-dark.png#only-dark)](devops-workflow-overview-large-dark.md)
