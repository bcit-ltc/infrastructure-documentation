# What is Kubernetes?

Kubernetes is a workload orchestration system that manages services on a cluster of servers. Clusters are groups of virtual machines (VM's) working together to create services for users.

Kubernetes monitors, schedules, and manages workloads so they are highly available.

## Kubernetes in real life (IRL)

An easy way to get started with Kubernetes is to download and run a local Kubernetes distribution. But because Kubernetes is resource-intensive, it's generally not a good idea to keep it running continuously; start one up, use it, and then stop it to preserve battery!

Some popular flavours that launch local Kubernetes clusters on your local machine are:

* [Minikube](https://minikube.sigs.k8s.io/docs/start/)
* [Rancher Desktop](https://rancherdesktop.io/)
* [MicroK8S](https://microk8s.io/)
* [K3S](https://k3s.io/)

Once you have a local cluster up and running, you are ready to install a couple of command-line utilities.

### `kubectl`

Deployments, services, ingresses, and other Kubernetes resources can be created and destroyed from the command line using the `kubectl` command.

> * See [kubectl documentation](https://kubectl.docs.kubernetes.io/guides/introduction/kubectl/).

!!! note "Installing command line utilities"

    **`kubectl`**

    === "brew (MacOS)"

        `brew install kubernetes-cli`


    === "choclatey (Windows)"

        `choco install kubernetes-cli`

    **`kubectx`**

    `kubectx` is also a time-saving tool that helps switch contexts if you are testing a deployment. You might as well install it now too.

### Cluster contexts

Local clusters create a *context* that you can connect to. Contexts require authentication, and the way you authenticate depends on your OS. When you install `kubectl`, it should automatically detect your local cluster's context and configure the authentication. If it doesn't you may need to run a `kubectl config...` command to change the context. Search Google for more info.

With the CLI utilities installed, and with a local cluster running, check connectivity:

    kubectl cluster-info

    kubectl get ns

If you don't see any namespaces, troubleshoot before moving on.

??? info "Working with many contexts"

    When working with several clusters, or when switching from a local cluster like Minikube to a remote cluster, the configuration for authenticating to these *contexts* is stored in a `~/.kube/config` file.

    Cluster contexts from various sources can be joined with commands like:

        # Make a copy of your existing config
        $ cp ~/.kube/config ~/.kube/config.bak

        # Merge the two config files together into a new config file
        $ KUBECONFIG=~/.kube/config:/path/to/new/config kubectl config view --flatten > /tmp/config

        # Replace your old config with the new merged config
        $ mv /tmp/config ~/.kube/config

        # (optional) Delete the backup once you confirm everything worked ok
        $ rm ~/.kube/config.bak

If everything looks good, you're ready to make your configuration files!

## Kubernetes tools

### FluxCD

[FluxCD](https://fluxcd.io/flux/) is a GitOps tool that constantly polls source code repositories for resources and reconciles the configuration on the cluster to match the source code.

### Kustomize

[Kustomize](https://kustomize.io) is a tool to build deployment configuration files for different contexts without duplicating content. Kustomize uses *overlays* to change deployment parameters from one configuration for a dev cluster to slightly different configuration for a production cluster.

Our template `deploy` folder uses Kustomize to ensure workloads are configured for the context they are being deployed to.

### Skaffold

[Skaffold](https://skaffold.dev) is a tool that, among other things, helps create and test deployment configuration files. By setting a default registry and connecting to a cluster, you can validate that your deployment will create the resources that you expect.

!!! tip "Getting started with Skaffold"

    Skaffold can auto-detect the type of resources you need for your app and suggest the files to create. Run the following:
    
        skaffold init

    Now, just make sure the context you need is selected by verifying with:

        kubectl cluster-info

    ??? note "Working with a remote cluster"
    
        If you're working with a remote cluster, define a default registry:
    
            skaffold config set default-repo registry.ltc.bcit.ca/{yourProjectPath}

One of the best features of Skaffold is the `dev` mode, which automates the mundane tasks of rebuilding an image, pushing it to a registry, and then deploying it to a cluster. Skaffold continuously watches folders for code changes and automatically takes care of the rebuilding, pushing to a registry, and deployment to a cluster!

Try it out by running:

    skaffold dev
