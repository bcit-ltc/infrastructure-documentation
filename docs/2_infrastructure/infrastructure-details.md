## Infrastructure Details

!!! warning "Under Construction"

    This page is still being written


### Virtual Machines

Our virtual machines (VM's) are provisioned by ITS using VMWare vSphere. The [vSphere hypervisor client interface](https://vcsa01.tis.bcit.ca/) is where we control the state of a VM (stopped, running, paused, snapshots, etc..).

The base image for all nodes is [CentOS 7.8](https://www.centos.org/download/), patched periodically with security updates by an [Ansible](https://docs.ansible.com/ansible/latest/user_guide/index.html) script. The one exception is a legacy Windows 2012R2 server that allows Course Production to use Respondus from their Mac laptops.


## Kubernetes

Most nodes are configured to be members of a [Kubernetes](https://kubernetes.io/docs/home/) cluster, and details of the LTC's setup are outlined on the [LTC Kubernetes](../1_kubernetes/index.md) page. Other VM's have different, specialized roles, described here.

## VM (Node) Roles

RKE2 is deployed on nodes destined to be Kubernetes members using the [rke2-ansible playbook](https://github.com/rancherfederal/rke2-ansible), and the configuration files are located in the [VM Node Configuration](https://issues.ltc.bcit.ca/ltc-infrastructure/vm-node-configuration) project.


The `ansible-rke2` collection is used to configure and provision the kubernetes clusters. See the `ansible-rke2/inventory` folder for a list of the current nodes, categorized by cluster.

* See the [RKE2 documentation](https://docs.rke2.io/).

After deploying RKE2, Rancher is installed via Helm using the Helm chart found in the [Rancher](https://issues.ltc.bcit.ca/ltc-infrastructure/rancher) project.

* See the [helm-install-rancher](helm-install-rancher) `values.yaml` file which is deployed using Terraform


### Manager nodes

- schedule and coordinate the deployment of workloads to available worker nodes


### Worker nodes

- contribute disk storage to the persistent disk storage provisioner, [Longhorn](https://www.longhorn.io)
- run container workloads

#### Longhorn

**Longhorn is used by all worker nodes**

Longhorn is a persistent disk provisioner for Kubernetes; it allows pods to request storage that remains available independent of the pod lifecycle. Regardless of the cluster, any node with a worker role (including the combo role) has an additional block device that is dedicated for use by Longhorn.

`ansible-node-configuration/playbooks/03_add_lvm_device.yaml` is used to configure the Longhorn block device settings. Devices are configured with an LVM-type disk so that it's easy to append more storage if it is needed later.

* In the `prod` cluster, the operator is deployed with the configuration files in the `Longhorn` project. This project also stores the terraform state files used to manage this service.
* In the `dev_cp`, `dev_vsm`, and `staging` clusters, the operator is deployed using the GUI: see details in the `Cluster Explorer` view under `Apps & Marketplace`.



## Load Balancer Roles

`(?:prod|dev)-gate*` nodes run the community version of [HAProxy](http://www.haproxy.org/) as a layer 4 load balancer (LB). DNS entries are updated programmatically using an Ansible script; details are in the [HAProxy](https://issues.ltc.bcit.ca/ltc-infrastructure/haproxy) project.

* HAProxy doesn't terminate SSL.
* The LB's have `firewalld` configured to block most traffic. See the `base-firewalld-config` path in the [VM Node Configuration](https://issues.ltc.bcit.ca/ltc-infrastructure/vm-node-configuration) project for playbooks that set this up.


## Legacy Systems

### Prod1

This is the original production web server that has existed since 2010 to serve the LTC's web apps. We are transitioning workloads off this Apache-based web server into containers that run on Kubernetes.

### Legacy Kubernetes

In 2018 a proof-of-concept Kubernetes cluster was built to research and validate Kubernetes technology. This set of servers was deployed with an old version of Rancher that uses Docker engine to run workloads. StorageOS was deployed as a persistent storage provisioner.

The cluster was installed without configuration files; all configuration was added through the GUI and is not recorded.


### Testing

One node has been reserved for testing - whatever that may be.


## Experimental

### Nomad server

Nomad is an alternative workload orchestrator that has been deployed as an R&D project. See https://learn.hashicorp.com/nomad


### Waypoint server

Waypoint is a development/deployment/release pipeline tool that has been deployed as a Nomad workload for R&D. See https://learn.hashicorp.com/waypoint.