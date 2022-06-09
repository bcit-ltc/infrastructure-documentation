# Configuring Infrastructure

!!! warning "Under Construction"

    This page is still being written

We strive to add or change infrastructure through declarative programming practices, where a desired state is coded into files that are then pushed to manage infrastructure.

## Infrastructure Configuration Requirements

If you are creating or changing infrastructure you will also need these tools:

- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-and-upgrading-ansible-with-pip)
- [Helm](https://helm.sh/docs/intro/install/)
- [Terraform](https://www.terraform.io/downloads.html)

!!! warning "Brand New Virtual Machines"

    Brand new VM's need to be configured with the `ansible` user before performing configuration changes.

## Infrastructure Tool Usage

### Ansible

[Ansible](https://docs.ansible.com/ansible/latest/user_guide/intro_getting_started.html#intro-getting-started) is used to bulk update virtual machines. Ansible connects to VM's via a pre-defined SSH key `(certs-keys/ansible/id_rsa)`, and then runs imperative scripts that are organized into "playbooks", "roles", or "tasks".

The VM's that playbooks connect to are listed in the `ansible-node-configuration/inventory/` path. Navigate to this path and run `ansible-inventory --graph` to see the details and groupings of the LTC's VM's.

To test that you can run a playbook, try running a `ping` test first:

`ansible-playbook basic_tasks/ping.yaml`

If the play fails, check that:

- you're connected to VPN
- the ansible user has been created on the VM
- the path to the `ansible` user's SSH key is located correctly in the `ansible.cfg` file. The path should be relative to the playbook's location.

If the `ansible` user hasn't yet been added to the server, run `00_add_user.yaml` with a user already on the system to get going ("ltc-admin" is added to all nodes automatically).

When the ping is successful, decide what the new node is for...

- k8s cluster manager
- k8s cluster worker
- load balancer
- etcd/consul cluster
- other (vault, admin, nomad, testing)

### Helm

Helm is a "package manager" for Kubernetes, and it's used here to deploy sets of resources to the clusters. Helm is normally run from the command line, which makes it difficult to record a "current state" of the deployment (anyone could login and run some commands and nobody would know what happened). In order to mitigate this, our Helm installs, are applied using [Terraform](https://www.terraform.io/docs/index.html) (see below), which allows us to record the deployment configuration in the version control system (VCS).

Helm chart configurations are generally stored in the `templates` path. When we want to deploy an application using a Helm chart, we use the Terraform Helm provider to deploy the chart so that we can commit the configuration using git. The current configurations that have been used (for applications deployed with Helm) are in the [LTC Infrastructure](https://issues.ltc.bcit.ca/ltc-infrastructure/ltc-infrastructure) repository.

### Terraform

Terraform is used to apply Helm charts to Kubernetes clusters in a way that allows us to record configuration settings and versions.

Terraform is a critical component of the managing the following projects:

- [Vault](https://issues.ltc.bcit.ca/ltc-infrastructure/vault-configuration)
- [Longhorn](https://issues.ltc.bcit.ca/ltc-infrastructure/longhorn)
- [Rancher](https://issues.ltc.bcit.ca/ltc-infrastructure/rancher)
- [GitLab Runner](https://issues.ltc.bcit.ca/ltc-infrastructure/gitlab-runner)
