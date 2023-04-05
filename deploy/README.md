# Deployment Package

## Overlay Development - Local cluster configuration

Learn how to customize this package for deployment on the [Infrastructure Documentation](https://infrastructure-documentation.ltc.bcit.ca/) website.

To test overlays on a local cluster (minikube, Rancher Desktop, etc...), you need to be able to pull images from a private registry.

### Requirements

- kpt
- kubectl-cli
- Docker
- a local cluster tool (minikube, k3s, Rancher Desktop, etc...)

### Configure an `ImagePullSecret` in `kustomization.yaml`

1) First, determine your GitLab username, password, and email
2) Create an `auth` token:

    ```
    printf "{yourLoginEmail}:{yourLoginPassword}" | base64
    ```

3) Create a `overlays/(TARGET_ENV}/secrets/.dockerconfigjson` with the following:

    ```
    {
        "auths": {
            "https://registry.ltc.bcit.ca": {
            "username": "{yourUsername}",
            "password": "{yourPassword}",
            "email": "{yourEmail}",
            "auth": "{yourAuthToken}"
            }
        }
    }
    ```

4) Uncomment the following sections in `kustomization.yaml`:

    ```
    secretGenerator:
    ...
    # - name: gitlab-registry-credentials
    #   type: kubernetes.io/dockerconfigjson
    #   files:
    #     - .dockerconfigjson=secrets/.dockerconfigjson

    patches:
    ...
    # - target:
    #     kind: Deployment
    #   patch: |-
    #     - op: add
    #       path: /spec/template/spec/imagePullSecrets
    #       value: [name: gitlab-registry-credentials]
    ```

5) Confirm the kustomization still renders correctly:

    ```
    kubectl kustomize overlays/review
    ```

6) Confirm your Kubernetes context

    ```
    kubectl config get-contexts
    ```

7) Initialize the overlay with `kpt`

    ```
    kpt live init overlays/{TARGET_ENV}
    ```

8) Apply the resource package to the cluster:

    ```
    kubectl kustomize overlays/{TARGET_ENV} | kpt live apply -
    ```

If the resources generate an error, destroy them, adjust the manifests, and try again.

An optional step is to validate resources by running the kpt `kubeval` function (requires Docker daemon to be running)

    ```
    kpt fn render overlays/review
    ```
