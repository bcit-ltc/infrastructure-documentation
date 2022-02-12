# Deployments and Releases

After an image is built, it is ready to be scheduled on a cluster as a workload. An image is a static collection of application "layers" that have been packaged according to a standardized specification. When an image is running, it is called a container.

Images by themselves don't have information to tell the cluster how they should scheduled. So when we are deploying an image to a cluster, we need to generate configuration files that specify to the cluster how to run the workload. The canonical Kubernetes resource that specifies how to run an image is called a **Deployment**.

This page describes the general steps involved in creating a deployment, as well as things to consider when the deployment is tagged as a ***Release***.

!!! info "Definitions"

    **Image**

    :   An application packaged in layers according to the Open Container Initiative (OCI) specification

    **Container**

    :   A running image

    **Deployment**

    :   A type of Kubernetes resource that specifies how to run an image on a cluster

    **Workload (also known as a Pod)**

    :   A deployment that is scheduled and running on a cluster

    **Release**

    :   A deployment that receives traffic


## Deploying a Workload

When an image is ready to be scheduled on a Kubernetes cluster, there are a few configuration files that need to be defined for the workload to run. Together, these files - and the image they refer to - are considered a **deployment**. When the deployment is scheduled and running on a cluster, it's called a **workload**.

![deployment image](../assets/deployment.png#only-light){ align=right }
![deployment image](../assets/deployment-dark.png#only-dark){ align=right }

!!! info ""

    A typical deployment has the following configuration files:

    * `ingress.yaml`
    * `service.yaml`
    * `deployment.yaml`

A Kubernetes resource called a **deployment** tells the cluster how to run the image, and resources like **service**, and **ingress** define how the cluster should connect to the workload.

!!! danger "Beware! Confusing Terminology"

    The term "deployment" can be used to describe a couple of different things:

    * the process of getting the image to the cluster and configuring it to run (usually via a CI/CD pipeline)
    * a Kubernetes resource that specifies how an image should run
    * a workload

    The context will help you determine which meaning is relevant.


### Workload Configuration Files

Configuration files are YAML formatted; they define the types of Kubernetes resources to create. Although they can be named anything, the names in our example files correspond to the type of resource that is created.

**`deployment.yaml`**

:   A resource that defines how an image should be configured to run.

**`service.yaml`**

:   A resource that abstracts the networking connection details away from a workload to create a persistent, reliable endpoint.

**`ingress.yaml`**

:   A resource that creates an endpoint to receive traffic from outside the cluster and route it to an internal resource, like a workload.

!!! example "An example deployment configuration file"

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx-deployment
      labels:
        app: nginx
    spec:
      replicas: 1
        spec:
          containers:
          - name: nginx
            image: nginx:1.14.2
            ports:
            - containerPort: 80
    ```

So how or where do we get these files? They can be created from scratch, but there are also tools that simplify the initial spec definition. The next section describes how this happens.


## Working with Kubernetes

>   * See the [Kubernetes section](../1_kubernetes/index.md) for more details about our Kubernetes architecture.

Besides the image and the workload configuration files, you need a cluster to deploy to! An easy way to get started is to download and run a local Kubernetes distribution, but because Kubernetes is resource-intensive, it's generally not a good idea to keep it running continuously; start one up, use it, and then stop it to preserve battery!

Some popular flavours that launch local Kubernetes clusters on your local machine are:

* [Minikube](https://minikube.sigs.k8s.io/docs/start/)
* [Rancher Desktop](https://rancherdesktop.io/)
* [MicroK8S](https://microk8s.io/)
* [K3S](https://k3s.io/)

Once you have a local cluster up and running, install a couple of command-line utilities.

- [Kubernetes-cli tools (eg. `kubectl`, `kustomize`)](https://kubernetes.io/docs/tasks/tools/)
- [Skaffold](https://skaffold.dev)


### kubectl

Deployments, services, ingresses, and other Kubernetes resources can be created and destroyed from the command line using the `kubectl` command.

>   * See [kubectl documentation](https://kubectl.docs.kubernetes.io/guides/introduction/kubectl/).

!!! note "Installing `kubectl`"

    === "brew (MacOS)"

            brew install kubernetes-cli

    === "choclatey (Windows)"

            choco install kubernetes-cli

!!! note ""

    `kubectx` is also a time-saving tool that helps switch contexts if you are testing a deployment. You might as well install it now too.

With the CLI utilities installed, and with a local cluster running, check connectivity:

    kubectl cluster-info

    kubectl get ns

If you don't see any namespaces, troubleshoot before moving on.

If everything looks good, you're ready to make your configuration files!


### Skaffold

[Skaffold](https://skaffold.dev) is a tool that helps create and test deployment configuration files. By setting a default registry and connecting to a remote cluster, you can validate that your deployment will create the resources that you expect.

!!! tip "Getting Started with Skaffold"

    Skaffold can auto-detect the type of resources you are creating and suggest the files to create.
    
        skaffold init

    Define a default registry:
    
        skaffold config set default-repo registry.dev.ltc.bcit.ca/{yourProjectPath}

One of the best features of Skaffold is the `dev` mode. This mode alleviates the mundane tasks of rebuilding an image, pushing it to a registry, and then deploying it to a cluster. Skaffold continuously watches folders for code changes and automatically takes care of the rebuilding, pushing to a registry, and deployment to a cluster!

    skaffold dev


### Kubernetes Contexts

When working with several clusters, or when switching from a local cluster like Minikube to a remote cluster, the configuration for authenticating to these *contexts* is stored in a `~/.kube/config` file.

Cluster contexts from various sources can be joined with commands like:

```bash
# Make a copy of your existing config
$ cp ~/.kube/config ~/.kube/config.bak

# Merge the two config files together into a new config file
$ KUBECONFIG=~/.kube/config:/path/to/new/config kubectl config view --flatten > /tmp/config

# Replace your old config with the new merged config
$ mv /tmp/config ~/.kube/config

# (optional) Delete the backup once you confirm everything worked ok
$ rm ~/.kube/config.bak
```


## Kustomize

[Kustomize](https://kustomize.io) is a tool to build deployment configuration files for different contexts without duplicating content. Kustomize uses overlays to change deployment parameters from one configuration for a dev cluster to slightly different configuration for a production cluster.


## CI/CD Pipelines

CI/CD stands for "continuous integration/continuous deployment", and it refers to an integration between the code base and the deployment environment. A CI/CD pipeline is a set of `jobs` that are configured to run automatically every time a new commit is pushed to a repository. These jobs can do many things, including testing code, building images, and pushing a deployment to a cluster. Examples of popular CI/CD pipeline tools are Drone, CircleCI, and TravisCI. GitLab comes with a built-in CI/CD sub-system; it relies on a "runner" and a `.gitlab-ci.yml` configuration file.

When an app is ready to be tested on a cluster, a commit to a repo configured with a `.gitlab-ci.yml` file triggers a pipeline that builds the app and then deploys it to a cluster.

The next section, [CI/CD Pipeline Details](pipeline-details.md) explains the details involved in each step of the template pipeline configuration file.
