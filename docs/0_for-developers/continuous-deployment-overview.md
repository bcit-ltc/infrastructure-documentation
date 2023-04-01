---
  title: "Continuous deployment"
---
<!-- markdownlint-disable MD025 -->

# Continuous deployment workflow

The default pipeline can help you get started automating your builds and deployments, but it's not configured to do much out-of-the-box; it requires configuration before you can see your app on a cluster.

After [initializing the project](./getting-started.md) the next step is to replace the generic deployment package. Here's how to replace the generic deployment package with one that is specific to your project.

!!! tip "Working knowledge of the following is helpful..."

    * Kubernetes resources(deployments, services, ingresses)
    * Basic Kustomize concepts (bases, overlays, builds)

## Deployment packages

Your source code project runs the pipeline that builds your app, but a second project called a ***deployment package*** actually deploys your app to Kubernetes.

The source code pipeline **triggers** a pipeline in the deployment package to deploy an app:

![Deployment Pipeline](../assets/deploy-pipeline-overview-light.png#only-light)
![Deployment Pipeline](../assets/deploy-pipeline-overview-dark.png#only-dark)

A deployment package is built around [`kustomize`](https://kubectl.docs.kubernetes.io/), where a *base* set of configuration files are modified by *overlays* before being applied to a cluster.

Deployment packages are pre-configured to deploy the `review` overlay to a review cluster, the `latest` overlay to the latest cluster, and the `stable` overlay to the stable cluster.

## `generic-dev` deployment package

When the [default GitLab ci/cd pipeline](https://issues.ltc.bcit.ca/-/snippets/60) is first used in your project, it deploys a generic package that verifies that GitLab can deploy to Kubernetes. If you create a merge request and a branch, and then commit a change and push this branch, the pipeline deploys the `generic-dev` deployment package to a `review` cluster. To view this `generic-dev` deployment, click on the `View App` button in the merge request.

The first step to replace the generic package is to create a project-specific deployment package.

1. Look for the following flag at the bottom of the `.gitlab-ci.yml` file:

        # DEPLOY_PKG_INIT='true'

2. Uncomment this flag and save the file
3. Commit and push the change

Uncommenting this flag triggers the creation of a template deployment package for your project. The process takes about 5 minutes and the new deployment package will be located in the [Deployments](https://issues.ltc.bcit.ca/deployments) group with the same name as your source code project.

## *Kustomizing* `generic-dev`

In GitLab, navigate to the [Deployments](https://issues.ltc.bcit.ca/deployments) group and clone your project's deployment package.

The newly-created deployment package contains example bases that might help give you an idea about how different workloads can be structured. The package also has boilerplate `review`, `latest`, and `stable` overlays that can be used as starting points for the kustomization.

Start by configuring the deployment package to use an `nginx-unprivileged` base with the `review` overlay:

### In the `deployment package` project

1. Navigate to the `overlays` > `review` path
2. Run a **search and replace** on the `review` overlay:

    - use the GUI to replace all instances of **"generic-dev"** (match whole word) with the name of your project (eg. **"qcon-web"**)

        ![replace all](../assets/replace-all.png)

    OR

    - run something like:

            sed -i -- 's/generic-dev/yourAppName/g' overlays/review/*

3. Commit and push the changes

### In the `app source code` project

1. Create an issue; call it something like *"initial deployment package"*
2. Create a merge request (MR) and a branch

    ![Create-MR-Branch](../assets/create-mr.png)

3. Checkout the branch; the branch name is at the top of the MR
4. Make a small change and save the change

    - eg. since the init has already been done it's safe to now comment out the `DEPLOY_PKG_INIT` flag

5. Commit and push the change
6. Navigate to the `CI/CD > Pipelines` page to monitor the pipeline progress

The pipeline will build an image and deploy it according to the configuration of the Kubernetes resource files in your deployment package.

!!! failure "If your pipeline fails..."

    You may need to make some small changes to your deployment package `review` overlay for the pipeline to complete successfully. Consider the following:

    - is `nginx` an appropriate base?
    - does your deployment require additional configuration (via a ConfigMap resource)?
    - does the base **Service** resource port need adjustment? If yes, don't change the base, just add a kustomize patch to the overlay.

## `latest` and `stable` overlays

After you have a working `review` overlay, most of the "heavy lifting" is done; the biggest difference between this overlay and the `latest`/`stable` overlays has to do with routing and security.

To deploy to `latest` or `stable`, follow the same steps to search and replace `generic-dev` with the project name, commit the changes, and then trigger a deployment by making a commit to the app source project on the `main` branch.
