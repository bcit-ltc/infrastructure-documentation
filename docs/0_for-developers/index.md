---
title: Overview
hide:
  - toc
---
<!-- markdownlint-disable MD025 -->

The LTC's infrastructure makes it easy to adopt a modern, automated, development workflow:

- [x] local development using `docker compose`
- [x] centralized version control, image registries, and automated deployment using [GitLab](https://gitlab.com)
- [x] a progressive release strategy using `review`, `latest`, and `stable` environments
- [x] `base` and `overlay` release packaging using [Kustomize](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)
- [x] secrets management using [Hashicorp Vault](https://www.vaultproject.io/docs)
- [x] automatic semantic versioning using [semantic-release](https://semantic-release.gitbook.io/semantic-release/)

![Deployment Pipeline](../assets/deploy-pipeline-overview-light.png#only-light)
![Deployment Pipeline](../assets/deploy-pipeline-overview-dark.png#only-dark)
