# Deployments and Releases

After an image is built, it can be scheduled on a cluster as a workload. An *image* is a static collection of application *layers* that have been packaged according to a standardized specification, but when an image is *running*, it is called a *container*.

Images only have information about themselves; they can't describe to the cluster how they should run. So when we are deploying an image to a cluster, we need to use configuration files to specify to the cluster how to run the workload. One of the most popular Kubernetes resources that specifies how to run an image is called a **Deployment**.

This page describes the general steps involved in creating a workload deployment, whether it's manually through the command line or using a CI/CD pipeline.

!!! info "Definitions"

    **Image**

    :   An application packaged in layers according to the *Open Container Initiative (OCI)* specification

    **Container**

    :   A running image

    **Deployment**

    :   A type of Kubernetes resource that specifies how to run an image on a cluster

    **Workload (also known as a Pod)**

    :   A deployment that is scheduled and running on a cluster

    **Release**

    :   A deployment that receives public traffic

## Deploying a Workload

When an image is scheduled on a Kubernetes cluster, configuration files define how the workload should run. Together, these files - and the image they refer to - are considered a **deployment**. When the deployment is scheduled and running on a cluster, it's called a **workload**.

![deployment image](../assets/deployment-light.png#only-light){ align=right }
![deployment image](../assets/deployment-dark.png#only-dark){ align=right }

!!! info ""

    A typical deployment package has the following *Kubernetes Resource Manifest (KRM)* files:

    * `ingress.yaml`
    * `service.yaml`
    * `deployment.yaml`

Kubernetes resources called **Deployments** tell the cluster how to run an image, and resources like **Services**, and **Ingresses** define how the cluster should connect to the workload.

!!! danger "Beware! Confusing Terminology"

    The terms "deployment" and "deployment package" can be used to describe a couple of different things:

    * the process of getting the image to the cluster and configuring it to run (usually via a CI/CD pipeline)
    * a Kubernetes resource that specifies how an image should run
    * a workload

    The context will help you determine which meaning is relevant.

### Workload Configuration Files

Configuration files are YAML formatted and they define the types of Kubernetes resources to create. Although they can be named anything, the names in the example files correspond to the types of resources that are created.

**`deployment.yaml`**

:   A resource that defines how an image should be configured to run.

**`service.yaml`**

:   A resource that abstracts the networking connection details away from a workload to create a persistent, reliable endpoint.

**`ingress.yaml`**

:   A resource that creates an endpoint to receive traffic from outside the cluster and route it to an internal resource, like a workload.

!!! example "An example `Deployment` Kubernetes resource manifest file"

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx-deployment
      labels:
        app: nginx
    spec:
      replicas: 3
        spec:
          containers:
          - name: nginx
            image: nginx:1.14.2
            ports:
            - containerPort: 80
    ```
