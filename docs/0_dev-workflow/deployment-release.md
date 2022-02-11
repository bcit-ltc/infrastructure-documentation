# Deployments and Releases

After an image has been built it is ready for deployment. An image is a static asset, but when it is running it is called a container.

This page describes the general steps involved in creating a deployment, as well as things to consider when the deployment is tagged as a ***Release***.

!!! info "Definitions"

    **Image**

    :   An application packaged in layers according to the Open Container Initiative (OCI) spec

    **Container**

    :   A running image

    **Deployment**

    :   An image that is configured to run on a Kubernetes cluster

    **Release**

    :   A deployment that receives traffic


## Creating Deployment Files

When an image is ready to be scheduled on a Kubernetes cluster there are a few configuration files that need to be defined for the workload to run. Together, these files - and the image they reference - are considered a ***Deployment***.

A typical deployment has the following configuration files:

* `deployment.yaml`
* `service.yaml`
* `ingress.yaml`

!!! example "Simple `deployment.yaml`"

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

Each configuration file defines how the Kubernetes cluster should create the resource.

**`deployment.yaml`**

:   Defines how an image should be configured to run; running images are also called **workloads**

**`service.yaml`**

:   A service abstracts the networking details away from a workload to create a persistent, reliable endpoint

**`ingress.yaml`**

:   Ingress refers to a resource that accepts traffic external to the cluster and routes it to an internal resource


How should these files be created? They can be created from scratch, but there are also tools that simplify the initial steps.

- [Skaffold](https://skaffold.dev)
- [Kubernetes-cli tools (eg. `kubectl`, `kustomize`)](https://kubernetes.io/docs/tasks/tools/)


## Working with Kubernetes

Besides the image and the deployment configuration files, you need a cluster to deploy to! An easy way to get started is to download and run a local Kubernetes distribution, but because Kubernetes is resource-intensive, it's generally not a good idea to keep it running continuously.

Some popular flavours that will get you going are:

* [Minikube](https://minikube.sigs.k8s.io/docs/start/)
* [Rancher Desktop](https://rancherdesktop.io/)
* [MicroK8S](https://microk8s.io/)
* [K3S](https://k3s.io/)

Once you have a local cluster up and running, install a couple of command-line utilities.


### kubectl

Workloads, services, ingresses, and other Kubernetes resources can be created and destroyed from the command line using the `kubectl` command.

See [kubectl documentation](https://kubectl.docs.kubernetes.io/guides/introduction/kubectl/).

!!! note "Installing `kubectl`"

    === "brew (MacOS)"

            brew install kubernetes-cli

    === "choclatey (Windows)"

            choco install kubernetes-cli

!!! note ""

    `kubectx` is also a time-saving tool that helps switch contexts if you are testing a deployment. Might as well install it now too.

With the CLI utilities installed, and with a local cluster running, check connectivity:

    kubectl cluster-info

    kubectl get ns

If you don't see any namespaces, troubleshoot before moving on.

If everything looks good, you're ready to make deployment configuration files!


### Skaffold

[Skaffold](https://skaffold.dev) is a tool that helps create and test deployment files. By setting a default registry and connecting to a remote cluster, you can validate that your deployment creates resources as expected.

!!! tip "Getting Started with Skaffold"

    Skaffold can auto-detect the type of resources you are creating and suggest the files to create.
    
        skaffold init

    Define a default registry:
    
        skaffold config set default-repo registry.dev.ltc.bcit.ca/{yourProjectPath}

If you do want to make code changes and rebuild the image, Skaffold can continuously watch folders for code changes and automate the rebuilding and pushing of an image to a cluster.

    skaffold dev

- a template `skaffold.yaml` file can be found in `Templates`>`skaffold.yaml` project


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


## CI/CD Pipelines

CI/CD stands for "continuous integration/continuous deployment", and it refers to an integration between the code base and the deployment environment. A CI/CD pipeline is a set of `jobs` that are configured to run automatically every time a new commit is pushed to a repository. These jobs can do many things, including testing code, building images, and pushing a deployment to a cluster. Examples of popular CI/CD pipeline tools are Drone, CircleCI, and TravisCI. GitLab comes with a built-in CI/CD sub-system; it relies on a "runner" and a `.gitlab-ci.yml` configuration file.

When an app is ready to be tested on a cluster, a commit to a repo configured with a `.gitlab-ci.yml` file triggers a pipeline that builds the app and then deploys it to a `dev` cluster.

A [separate document](pipeline-details.md) explains the details involved in each step of the template pipeline config file.

!!! example "Triggering a CI/CD Pipeline"

    1. Create an Issue
    1. Create a Merge Request and a branch

        ![MR-Branch](../assets/mr-branch.png)
    1. Open a code editor and checkout the new branch
    1. Develop locally using `docker compose up` and `skaffold dev`
    1. Commit changes and push to GitLab
