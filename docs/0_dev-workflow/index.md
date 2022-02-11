---
title: Overview
---

The LTC's infrastructure was re-designed to make it easy to adopt a modern, automated, development workflow:

1. local development and image builds using `docker compose`
1. centralized version control using GitLab
1. private image registries using [GitLab Registry](https://docs.gitlab.com/ee/user/packages/container_registry/)
1. dev deployment testing using [Skaffold](https://skaffold.dev)
1. modified environments for dev, staging, and production using [Kustomize](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)
1. cluster deployment using [GitLab Runner CI/CD pipeline](https://docs.gitlab.com/ee/ci/)
1. standarized in-cluster image building using [Kaniko](https://github.com/GoogleContainerTools/kaniko)
1. secrets management using [Hashicorp Vault](https://www.vaultproject.io/docs)
1. git tagged semantic versioning using [semantic-release](https://semantic-release.gitbook.io/semantic-release/)
1. production cluster deployment and releases using [GitLab Releases](https://docs.gitlab.com/ee/user/project/releases/)

----

[![Development workflow](../assets/dev-workflow-overview.png#only-light)](../assets/dev-workflow-overview.png)
[![Development workflow](../assets/dev-workflow-overview-dark.png#only-dark)](../assets/dev-workflow-overview-dark.png)