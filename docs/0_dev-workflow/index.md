---
title: Overview
---

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

----

This diagram is an overview of the major components of our development workflow:

[![Development workflow](../assets/dev-workflow-overview.png#only-light)](../assets/dev-workflow-overview.png)
[![Development workflow](../assets/dev-workflow-overview-dark.png#only-dark)](../assets/dev-workflow-overview-dark.png)
