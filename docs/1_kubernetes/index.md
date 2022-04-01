---
title: Overview
---

## What is Kubernetes?

Kubernetetes is a workload orchestration system that administers services on a cluster of servers. More often than not, the servers are virtual machines (VM's) working together to create services for users.

Kubernetes monitors, schedules, and manages so that workloads (like web applications) are highly available and flexibly routable.

## RKE2

[SUSE Rancher RKE2](https://github.com/rancher/rke2/) is the flavour of Kubernetes we use to create Kubernetes clusters. It was chosen because it is open-source, free, and relatively easy to operate and use.

The VM's in a cluster are called **nodes**, and nodes can have different **roles** depending on the type of cluster.

## Rancher

One of the more important workloads that runs on the "admin" RKE2 cluster is called Rancher. Rancher is an application that allows us to administer each of the clusters from a central interface.

> * [https://rancher2.ltc.bcit.ca](https://rancher2.ltc.bcit.ca)
