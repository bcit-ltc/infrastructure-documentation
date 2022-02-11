# Cluster Details

Clusters are collections of virtual machines working together. The VM's in a cluster are called nodes, and nodes can have different roles depending on the type of cluster.


## Kubernetes Cluster Roles

[SUSE Rancher RKE2](https://github.com/rancher/rke2/) is the flavour of Kubernetes we use to deploy Kubernetes clusters. It was chosen because it is open-source, free, and relatively easy to operate/use. RKE2 is deployed on nodes destined to be Kubernetes members using the [rke2-ansible playbook](https://github.com/rancherfederal/rke2-ansible), and the configuration files are located in the [VM Node Configuration](https://issues.ltc.bcit.ca/ltc-infrastructure/vm-node-configuration) project.

Kubernetes cluster nodes provisioned by RKE2 can have 3 possible roles:
- **Manager:** runs kubernetes `control` and `etcd` processes in a "management plane" to coordinate, schedule, and manage workloads
- **Worker:** runs workloads and provisions storage capacity through [Longhorn](https://www.longhorn.io)
- **Combo:** runs both manager and worker roles

Different clusters (admin, prod, staging, etc...) use a mix of different roles: development, staging, and admin clusters use combo (manager+worker) roles, whereas production clusters use dedicated manager and worker roles.


## Cluster Specifics


### Production (prod)
- manager nodes do not run workloads
- worker nodes contribute storage to the persistent disk provisioner, Longhorn.


### Staging/Dev (staging, dev_cp, dev_vsm)
- all nodes run combo (manager+worker) roles


### Rancher Admin

Rancher is a GUI interface for kubernetes. `prod-admin*` nodes run the Rancher application in a highly available configuration. After deploying RKE2, Rancher is installed via Helm using the Helm chart found in the [Rancher](https://issues.ltc.bcit.ca/ltc-infrastructure/rancher) project.

* See the [helm-install-rancher](helm-install-rancher) `values.yaml` file which is deployed using Terraform
