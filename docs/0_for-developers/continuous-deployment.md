---
  title: "Continuous deployment"
---
<!-- markdownlint-disable MD025 -->

# Continuous deployment workflow

The default pipeline file can help you get started with an automated build and deploy, but it's not configured to do much out-of-the-box - it requires configuration before you can see your app on a cluster.

After [initializing the project](./getting-started.md) the next step is to replace the generic deployment package. Here's how to replace the generic deployment package with one that is specific to your project.

!!! warning "Requirements"

    This page assumes some working knowledge of the following:

    * Basic Kubernetes concepts (deployments, services, ingresses)
    * Basic Kustomize concepts (bases, overlays)

    See the [tech stack documentation](../1_tech-stack-documentation/index.md) for LTC-curated resources or see the respective technology's documentation.

## Deployment packages

Your source code project runs the pipeline that builds your app, but there's a second project called a ***deployment package*** that deploys your app to Kubernetes.

The source code pipeline **triggers** a pipeline in the deployment package to deploy an app:

![Deployment Pipeline](../assets/deploy-pipeline-overview-light.png#only-light)
![Deployment Pipeline](../assets/deploy-pipeline-overview-dark.png#only-dark)

A deployment package is built around [`kustomize`](https://kubectl.docs.kubernetes.io/), where a *base* set of configuration files are modified by *overlays* before being applied to a cluster.

The `.gitlab-ci.yml` pipeline file in a deployment package is pre-configured to deploy the `dev` overlay to a dev cluster, the `staging` overlay to the staging cluster, and the `production` overlay to the production cluster.

## LTC `generic-dev` deployment package

When the [default GitLab ci/cd pipeline](https://issues.ltc.bcit.ca/-/snippets/60) is first used in your project, it deploys a generic package that verifies that GitLab can deploy to Kubernetes. If you create a merge request and a branch, and then commit and push to this branch, the pipeline deploys the `generic-dev` deployment package to your `dev` cluster. To view it, click on the `View App` button in the merge request.

The first thing to do to move away from a generic package is to create a project-specific deployment package.

1. Look for the following flag at the bottom of the `.gitlab-ci.yml` file:

        # DEPLOY_PKG_INIT='true'

1. Uncomment this flag and save the file
1. Commit and push the change

Uncommenting this flag triggers the creation of a simple deployment package for your project. The process takes about 5 minutes and the new deployment package will be located in the [Deployments](https://issues.ltc.bcit.ca/deployments) group with the same name as your source code project.

## *Kustomizing* `generic-dev`

!!! tip inline end ""

    Deployment packages are initially replicas of the `generic-dev` deployment package.

In GitLab, navigate to the [Deployments](https://issues.ltc.bcit.ca/deployments) group and clone your project's deployment package.

The newly-created deployment package contains example bases that might help give you an idea about how different workloads can be structured. The package also has example `dev`, `staging`, and `production` overlays that can be used as starting points for the kustomization.

For now, let's configure the deployment package to use an `nginx-unprivileged` base with a `dev` overlay:

**In the `deployment package` project:**

1. Navigate to the `overlays` > `dev` path
1. Run a **search and replace** on the `dev` overlay:

    - use the GUI to replace all instances of **"generic-dev"** (match whole word) with the name of your project (eg. **"ltc-infrastructure"**)

        ![replace all](../assets/replace-all.png)

    OR

    - run something like:

            sed -i -- 's/generic-dev/yourAppName/g' overlays/dev/*

1. Commit and push the changes

**In the `source code` project:**

1. Create an issue; call it something like *"initial deployment package deployment"*
1. Create a merge request (MR) and a branch

    ![Create-MR-Branch](../assets/create-mr.png)

1. Checkout the branch; the branch name is at the top of the MR
1. Make a small change and save the change

    - eg. comment out the `DEPLOY_PKG_INIT` flag

1. Commit and push the change
1. Navigate to the `CI/CD > Pipelines` page to monitor the pipeline progress

The pipeline will build an image and deploy it according to the configuration of the Kubernetes resource files in your deployment package.

!!! failure "If your pipeline fails..."

    You may need to make some small changes to your deployment package `dev` overlay for the pipeline to complete successfully. Consider the following:

    - is `nginx` an appropriate base?
    - does your deployment require additional configuration (via a ConfigMap resource)?
    - does the base **Service** resource port need adjustment? If yes, don't change the base, just add a service patch to the `dev` overlay.

## `staging` and `production` overlays

After you have a working `dev` overlay, most of the "heavy lifting" is done; the biggest difference between the `dev` overlay and the `staging`/`production` overlays has to do with routing and security.

To deploy to `staging` or `production`, either rename the overlays (eg. from `{--staging-example--}` to `{++staging++}`), or copy the `dev` overlay into an appropriate path and add the following:

- `serviceaccount.yaml`
- in `ingress.yaml`, add **tls** configuration:

        spec:
        tls:
        - hosts:
            - stable.ltc.bcit.ca
            secretName: star-ltc-bcit-ca
- in `kustomization.yaml`, add the `ServiceAccount` resource

### Secrets

If your application uses any kind of secret, you should be storing and retrieving these from [Vault](https://vault.ltc.bcit.ca).

Use the following annotations in your `staging` and `production` overlays to configure automatic secret retrieval:

=== "staging"

        kind: Deployment
        spec:
            template:
                metadata:
                annotations:
                    vault.hashicorp.com/agent-inject: 'true'
                    vault.hashicorp.com/role: '{projectName}-staging-kubeauthbot'
                    vault.hashicorp.com/agent-inject-secret-config: 'web-apps/data/{projectName}'
                    vault.hashicorp.com/agent-inject-template-config: |
                    {{ with secret "web-apps/data/{projectName}" -}}
                    {secretKey}="{{ .Data.data.{secretKey} }}"
                    {{- end }}

=== "production"

        kind: Deployment
        spec:
            template:
                metadata:
                annotations:
                    vault.hashicorp.com/agent-inject: 'true'
                    vault.hashicorp.com/role: '{projectName}-production-kubeauthbot'
                    vault.hashicorp.com/agent-inject-secret-config: 'web-apps/data/{projectName}'
                    vault.hashicorp.com/agent-inject-template-config: |
                    {{ with secret "web-apps/data/{projectName}" -}}
                    {secretKey}="{{ .Data.data.{secretKey} }}"
                    {{- end }}

### Routing

The permalinks used by the ingress resources follow a predictable pattern:

<!-- markdownlint-disable MD034 -->

| Cluster      | URL                                                                 |
| -----------  | ------------                                                        |
| `dev`        | **http://**`{projectName}`./`{clusterName}`.reviews.dev.ltc.bcit.ca |
| `staging`    | https://latest.dev.ltc.bcit.ca/`{projectName}`                      |
| `production` | https://stable.dev.ltc.bcit.ca/`{projectName}`                      |

To configure a unique URL for your app, setup an additional **public-endpoint** ingress. In `overlays` > `production`, edit `public-endpoint.yaml`:

- change all instances of `generic-dev` to a unique name for your app:

        ...
        spec:
            tls:
            - hosts:
                - {--generic-dev--}{++{appName}++}.ltc.bcit.ca
                secretName: star-ltc-bcit-ca
            rules:
            - host: {--generic-dev--}{++{appName}++}.ltc.bcit.ca
        ...
