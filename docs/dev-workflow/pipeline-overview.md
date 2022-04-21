# CI/CD Pipeline Overview

!!! warning "Under Construction"

    This page is still being written...

The default LTC pipeline runs the following jobs:

1. project initialization
1. gather_info
1. build
1. deploy

Pushing a commit triggers a CI/CD pipeline that builds your application and deploys it to a dev cluster.

## Repository Configuration

To get started, make sure your project has the following:

1. `Dockerfile` - the configuration file that tells the system how to build an image of your app
1. a `.gitlab-ci.yml` file
    - the [Default LTC GitLab CI/CD Pipeline](https://issues.ltc.bcit.ca/-/snippets/60) file can be added to any project with a Dockerfile to get started

Once you have a `Dockerfile` and a `.gitlab-ci.yml` file, create an issue, a merge request, and a branch to trigger the CI/CD pipeline.

!!! example "Working with the CI/CD Pipeline"

    1. Create an Issue
    1. Create a Merge Request and a branch

        ![Create-MR-Branch](../assets/create-mr.png)

    1. Open a code editor and checkout the new branch
    1. Develop locally using `docker run...`, `docker compose up`, and/or `skaffold dev`
    1. Commit changes and push back to the repo

## Semantic Versioning

We use [Semantic Versioning](https://semver.org/) to automatically determine whether a tag is considered "major", "minor", or "patch. [`semantic-release`](https://semantic-release.gitbook.io/semantic-release/) analyzes commit messages and increments versions based on the type of keyword included in a commit message.

To begin using semver tagging in your projects, add any of the following keywords to the beginning of your commit messages:

| **Prefix:** ...commit message...          | Release type  |
| ----------------------                    | ------------  |
| `fix: ...some smaller bugfix...`          | patch         |
| `feat: ...add functionality message...`   | minor         |
| `breaking: ...big version change...`      | major         |

## Deployment Packages

The default pipeline file can help you get started with an automated build and deploy, but it's not configured to do much out of the box - it requires some configuration before you can see your app on a cluster.

Up until now, we've talked about the `Dockerfile` and the `CI/CD pipeline configuration file`. But the other part of the picture is the set of KRM's you use to tell the cluster how to deploy your app. These files are called a **deployment package**.

A deployment package is built around [`kustomize`](https://kubectl.docs.kubernetes.io/), where there's a base set of configuration files that get modified by *overlays* based on the cluster they're being applied to.

Here's what the structure of a kustomize-based deployment package looks like:

![kustomized deploy package](../assets/kustomized-deploy-pkg.png)

The files in the `dev` path are *patches* that configure the deployment for a `dev` cluster. Similarly, the files in the `production` path are patches for the `production` cluster.

!!! tip "Creating a Deployment Package"

    To have the Default CI/CD pipeline create a "generic" deployment package that you can start working with, look for the **DEPLOY_PKG_INIT** flag at the bottom of the `.gitlab-ci.yml` file and uncomment it. Commit this change to trigger the creation of a simple deployment package.

Once this deployment package has been created, it can be *kustomized* to work with your app image so that it can be deployed to a cluster.
