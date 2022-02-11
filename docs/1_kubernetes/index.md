---
title: Overview
---

## General Notes

Kubernetetes is a workload orchestration system. It monitors, schedules, and administers workloads (for example, web applications), so that the workload is highly available and flexibly routable.

!!! note ""

    Our Kubernetes clusters are provisioned with [SUSE/Rancher RKE2](https://github.com/rancher/rke2/).


## Kustomize

[Kustomize](https://kustomize.io) is a tool to build deployment configuration files for different contexts without duplicating content. Kustomize uses overlays to change deployment parameters from one configuration for a dev cluster to slightly different configuration for a production cluster.
