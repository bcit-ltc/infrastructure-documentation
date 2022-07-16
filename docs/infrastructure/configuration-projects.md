# LTC Infrastructure Configuration Projects

!!! warning "Under Construction"

    This page is still being written

Projects in the `LTC Infrastructure` group contain the configuration files for a variety of services. The projects and their purpose are briefly described below.

## Infrastructure Documentation

This site!

## VM Node Configuration

When a new VM is provisioned by ITS, the Ansible scripts in this project are used to configure the node for a variety of roles.

## Inventory

This repo contains the authoritative source of LTC server information.

## [Traefik-docker](https://issues.ltc.bcit.ca/ltc-infrastructure/traefik-docker)

Traefik is the load balancer entrypoint for the LTC's web apps and services. It sits in the DMZ and forwards traffic to apps that run on Kubernetes clusters. Traefik runs inside a docker container to enable version-controlled releases and roll-backs.

A corresponding "Traefik-docker-dev" project houses the load balancer configuration for `dev-gate3`.

## [Vault](https://issues.ltc.bcit.ca/ltc-infrastructure/vault-configuration)

Vault is the LTC's secrets management platform. This project houses the configuration of secrets engines, not the secrets themselves.

Vault is currently deployed as a single-node resource (which eases backup/restore operations) with integrated `Raft` storage.

* Vault was provisioned with the `deploy_vault.yaml` playbook, which uses configuration settings in the `templates/vault` path. See the [Hashicorp Vault Production Deployment Guide](https://learn.hashicorp.com/tutorials/vault/raft-deployment-guide?in=vault/day-one-raft).

## Error Pages

This project houses the error pages for the `*.ltc.bcit.ca` and `*.dev.ltc.bcit.ca` domains.

## Configuration Development

This sub group is a place to start projects for automating infrastructure. Projects that have been tested and are in general use should be moved out of this subgroup into the main `LTC Infrastructure` group.

## Base Images

This project houses the configuration and base images used in other projects. Checkout a branch to update an image.

## GitaLab Runner

GitLab Runner is the CI/CD pipline agent that performs actions to build and deploy apps. This repo stores the Terraform state file and Helm `values.yaml` used to deploy this service.

## Certs/Keys

Houses TLS certs and keys for the `*.ltc.bcit.ca` and `*.dev.ltc.bcit.ca` domains.

## Longhorn

Longhorn is the name of the service that provisions persistent storage in the LTC's Kubernetes clusters. This repo stores the Terraform state file and Helm `values.yaml` used to deploy this service.

## Rancher

Rancher is the administrative GUI front-end to the LTC's Kubernetes clusters. This repo stores the Terraform state file and Helm `values.yaml` used to deploy this service.
