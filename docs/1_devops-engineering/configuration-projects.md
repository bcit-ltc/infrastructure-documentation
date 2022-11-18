# LTC Infrastructure Configuration Projects

Projects in the `LTC Infrastructure` group contain the configuration files for a variety of services.

## Infrastructure Documentation

This site!

## VM Node Configuration

When a new VM is provisioned by ITS, the Ansible scripts in this project are used to configure the node. The scripts perform operations like:

* update `firewalld` rules
* manage lvm disk space
* install common packages
* copy certificates
* manage users

## Inventory

This repo contains the authoritative source of LTC server information.

## [Traefik-docker](https://issues.ltc.bcit.ca/ltc-infrastructure/traefik-docker)

Traefik is the load balancer entrypoint for the LTC's web apps and services. It sits in the DMZ and forwards traffic to apps that run on Kubernetes clusters.

A corresponding "Traefik-docker-dev" project houses the load balancer configuration for `dev-gate3`.

## [Vault](https://issues.ltc.bcit.ca/ltc-infrastructure/vault-configuration)

Vault is the LTC's secrets management platform. This project houses the configuration of secrets engines, not the secrets themselves.

Vault is currently deployed as a single-node resource (which eases backup/restore operations) with integrated `Raft` storage.

* See the [Hashicorp Vault Production Deployment Guide](https://learn.hashicorp.com/tutorials/vault/raft-deployment-guide?in=vault/day-one-raft).

## Configuration Development

This sub-group is a place to start projects for automating infrastructure. Projects that have been tested and are in general use should be moved into the main `LTC Infrastructure` group.

## Base Images

This project houses the configuration and base images used in other projects. Checkout a branch to view or update an image.

## GitaLab Runner

GitLab Runners are the CI/CD pipline agents that build and deploy apps. This repo stores the Terraform state file and Helm `values.yaml` used to deploy these agents.

## Certs/Keys

Houses TLS certs and keys for the `*.ltc.bcit.ca` and `*.dev.ltc.bcit.ca` domains.

## Longhorn

Longhorn provisions persistent storage in the LTC's Kubernetes clusters. This repo stores the Terraform state file and Helm `values.yaml` used to deploy this service.

## Rancher

Rancher is the administrative GUI front-end to the LTC's Kubernetes clusters. This repo stores the Terraform state file and Helm `values.yaml` used to deploy this service.
