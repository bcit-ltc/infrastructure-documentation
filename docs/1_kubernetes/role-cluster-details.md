# Roles and Cluster Details

!!! warning "Under Construction"

    This page is still being written

Kubernetes cluster nodes provisioned by RKE2 have 3 roles: Manager, Worker, or Combo (Manager+Worker).

!!! info "RKE2 Node Roles"

    `Manager`

    :   runs kubernetes `control` and `etcd` processes in a "management plane" to coordinate, schedule, and manage workloads

    `Worker`

    :   runs workloads and provisions storage capacity through Longhorn

    `Combo`

    :   runs both manager and worker roles

Different clusters (admin, prod, staging, etc...) use a mix of different roles.

## Cluster Details

### Production

![prod-cluster diagram](../assets/prod-cluster.png#only-light)
![prod-cluster diagram dark](../assets/prod-cluster-dark.png#only-dark)

* manager nodes do not run workloads, they are dedicated `manager` nodes
* there are three nodes to ensure replication and high availability
* worker nodes run workloads and contribute storage to the persistent disk provisioner, Longhorn.

### Staging

![staging-cluster diagram](../assets/staging-cluster.png#only-light)
![staging-cluster diagram dark](../assets/staging-cluster-dark.png#only-dark)

* all nodes run combo (manager+worker) roles

### Dev_cp and Dev_vsm

* all nodes run combo (manager+worker) roles

### Rancher Admin

[Rancher](https://www.suse.com/products/suse-rancher/) is a UI interface for Kubernetes that runs as a workload in a dedicated **admin** cluster. Rancher helps us visually understand what is happening in our Kubernetes clusters.

* `prod-admin*` nodes run the Rancher application in a highly available configuration.
* all nodes run combo (manager+worker) roles

## Common Cluster Components

### Rancher "Projects"

Projects are Rancher constructs that help organize namespaces. See [Rancher Docs - Project Administration](https://rancher.com/docs/rancher/v2.6/en/project-admin/).

### `nginx` Ingress

Rancher's default Ingress is powered by nginx. See [Rancher Docs - Adding Ingresses](https://rancher.com/docs/rancher/v2.6/en/k8s-in-rancher/load-balancers-and-ingress/ingress/) for more info.

### Longhorn

**Longhorn is used by all worker nodes**

[Longhorn](https://www.longhorn.io) is a persistent disk provisioner for Kubernetes; it allows pods to request storage that remains available independent of the pod lifecycle. Regardless of the cluster, any node with a worker role (including the combo role) has an additional block device that is dedicated for use by Longhorn.

### GitLab Runner

GitLab Runner is an application that works with the GitLab CI/CD pipeline coordinator to run the jobs specified in a CI/CD pipeline. GitLab Runner has been deployed in the `Utilities` project on each of the clusters so that our pipelines can deploy to our clusters.
