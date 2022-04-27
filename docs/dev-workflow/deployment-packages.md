# Deployment Packages

!!! warning "Under Construction"

    This page is still being written...

The default pipeline file can help you get started with an automated build and deploy, but it's not configured to do much out of the box - it requires configuration before you can see your app on a cluster.

Up until now, we've talked about the `Dockerfile` and the `CI/CD pipeline configuration file`. But the other part of the picture is the set of KRM's you configure to tell the cluster how to deploy your app. Together, these files are called a **deployment package**.

## Pipelines and Deployment Packages

Your source code project runs the pipeline that builds and deploys your app. The diagram below outlines how the pipeline gets triggered and how the deployment package gets deployed to the dev cluster.

![Deployment Pipeline](../assets/deployment-package-apply.png#only-light)
![Deployment Pipeline](../assets/deployment-package-apply-dark.png#only-dark)

## Kustomize Concepts

A deployment package is built around [`kustomize`](https://kubectl.docs.kubernetes.io/), where a base set of configuration files get modified by *overlays* based on the cluster they're being applied to.

Here's what the structure of a kustomize-based deployment package looks like:

<!-- markdownlint-disable MD033 -->
<figure markdown>
![kustomized deploy package](../assets/kustomize.png){ width="500" }
  <figcaption>An example `nginx` deployment package</figcaption>
</figure>

### The Base

The base in the example above consists of some standard Kubernetes Resource Manifests:

* `deployment.yaml`
* `service.yaml`

Because this package is based on `nginx`, it also includes a `configmap.yaml` that houses `nginx.conf` settings.

The README.md is self explanatory, but the two other files are worth describing:

`Kptfile`

:   A `kpt` package identifier. It contains *inventory* details about all the resources that are applied to the cluster together.

`kustomization.yaml`

:   A kustomize specification file. It describes the resources that should be applied to the cluster.

### The Overlay

The files in the overlay are *patches* that describe how a resource is changed when it is applied to a cluster. In the example above, the `dev` cluster overlay adds an `ingress.yaml` and a `namespace.yaml` file to ensure 1) traffic can be routed to the workload, and 2) the worklaod is deployed to a known location. In a fully-configured deployment package, there are similar files in the `staging` and `production` overlays which make adjustments to the workloads applied to the `staging` and `production` clusters, respectively.

## LTC `generic-dev` deployment package

The default deployment package contains some example bases that might help give you an idea about how different workloads can be structured. The package also has an example `dev` overlay that demonstrates how a deployment is patched for a development cluster.

=== "nginx-unprivileged"

    * deployment.yaml
    * service.yaml

=== "mysql"

    * deployment.yaml
    * pvc.yaml
    * service.yaml

=== "nodejs-mongodb"

    * `mongo-express`
        * deployment.yaml
    * service.yaml

=== "wordpress"

    * `deployment`
        * volume.yaml
        * wordpress-deployment.yaml
    * `mysql`
        * mysql-deployment.yaml
    * service.yaml

=== "`dev` overlay"

    * ingress.yaml
    * namespace.yaml

!!! tip "Creating a Deployment Package for your project"

    To have the [Default LTC GitLab CI/CD Pipeline](https://issues.ltc.bcit.ca/-/snippets/60) automatically create a deployment package that you can start working with, look for the following flag at the bottom of the `.gitlab-ci.yml` file:
    
        # DEPLOY_PKG_INIT='true'
    
    Uncomment it. Commit and push this change to trigger the creation of a simple deployment package for your project.

    The process takes about 5 minutes and the new deployment package will be located in the [Deployments](https://issues.ltc.bcit.ca/deployments) group.

    The deployment package is a replica of the `generic-dev` deployment package. Navigate to the `deployments` group and clone your project's deployment package to get started.

## First steps *kustomizing* the Deployment Package

One of the easiest ways to update your app's deployment package is to do a "search and replace" on the dev overlay.

    sed -i -- 's/generic-dev/yourAppName/g' *

The pipeline will look for a file in your project's registry and deploy it with sane defaults.
