# Deployment Package

## Overlay Development - Local cluster configuration

Learn how to customize this package for deployment on the [Infrastructure Documentation](https://infrastructure-documentation.ltc.bcit.ca/) website.

To test overlays on a local cluster (minikube, Rancher Desktop, etc...), you need to be able to pull images from a private registry.

### Requirements

- [kpt](https://kpt.dev)
- kubectl-cli
- Docker
- a local cluster tool (minikube, k3s, Rancher Desktop, etc...)

### Configure an `ImagePullSecret` in `kustomization.yaml`

1) First, set your GitLab username, password, and email
   
   ```
   export USER="{yourUsername}" PASSWORD="{yourBCITpassword}" EMAIL="{yourBCITemail}"
   ```

2) Create an `${AUTH_TOKEN}` token:

    ```
    export AUTH_TOKEN=$(printf "${USER}:${PASSWORD}" | base64)
    ```

3) Set a target environment:
   
   ```
   export TARGET_ENV=review
   ```

4) Create a `.dockerconfigjson` in the secrets path:

    ```
cat <<EOF > overlays/${TARGET_ENV}/secrets/.dockerconfigjson
{
    "auths": {
        "https://registry.ltc.bcit.ca": {
        "username": "${USER}",
        "password": "${PASSWORD}",
        "email": "${EMAIL}",
        "auth": "${AUTH_TOKEN}"
        }
    }
}
EOF
    ```

5) Uncomment the following sections in the `kustomization.yaml`:

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

6) Create a fake `tls.crt` and `tls.key`
   
   ```
   echo "fake key" > overlays/${TARGET_ENV}/secrets/tls.key \
   && echo "fake cert" > overlays/${TARGET_ENV}/secrets/tls.crt
   ```

7) Initialize the overlay for `kpt`
   
   ```
   kpt live init overlays/${TARGET_ENV}
   ```

8) Confirm the kustomization still renders correctly:

    ```
    kubectl kustomize overlays/${TARGET_ENV}
    ```

9)  Confirm your Kubernetes context (should match your local kubernetes cluster)

    ```
    kubectl config get-contexts
    ```

10) Add a namespace

    ```
    kubectl create ns {yourProjectName}
    ```

11) Apply the resource package to the cluster:

    ```
    kubectl kustomize overlays/${TARGET_ENV} | kpt live apply -
    ```

12) Unset sensitive variables

    ```
   unset \
   USERNAME={yourUsername} \
   PASSWORD={yourBCITpassword} \
   EMAIL={yourBCITemail} \
   AUTH_TOKEN
    ```

If the resources generate an error, destroy them, adjust the manifests, and try again.

An optional step is to validate resources by running the kpt `kubeval` function (requires Docker daemon to be running)

    ```
    kpt fn render overlays/${TARGET_ENV}
    ```
