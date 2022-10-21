---
  title: "Overview"
---
<!-- markdownlint-disable MD025 -->

# CI/CD Pipelines

A CI/CD pipeline is an infrastructure function that watches repositories for changes and then performs actions when a new commit is pushed. Our CI/CD pipelines build images and deploy them to a cluster.

CI/CD stands for "continuous integration/continuous deployment", and it refers to an integration between the code base and the deployment environment. A CI/CD pipeline is a set of `jobs` that are configured to run automatically every time a new commit is pushed to a repository. These jobs can do many things, including testing code, building images, and pushing a deployment to a cluster. Examples of popular CI/CD pipeline tools are Drone, CircleCI, and TravisCI.

GitLab comes with a built-in CI/CD sub-system; it relies on a "runner" and a `.gitlab-ci.yml` configuration file.

When an app is ready to be tested on a cluster, a commit to a repo configured with a `.gitlab-ci.yml` file triggers a pipeline that builds the app and then deploys it to a cluster.

![Deployment Pipeline](../assets/deployment-package-apply.png#only-light)
![Deployment Pipeline](../assets/deployment-package-apply-dark.png#only-dark)

## Requirements

1. `Dockerfile` - the configuration file that tells the system how to build an image of your app
1. `.gitlab-ci.yml` file

The [Default LTC GitLab CI/CD Pipeline](https://issues.ltc.bcit.ca/-/snippets/60) file can be added to any project with a Dockerfile to get started.

Once you have the requirements met, commit your files to trigger the pipeline.

## Stages

The default LTC pipeline has the following stages or steps:

1. project init
1. gather info
1. build an image
1. deploy

Pushing a commit triggers the pipeline to run through each of these stages.

!!! example "Working with the CI/CD Pipeline"

    1. Create an Issue
    1. Create a Merge Request and a new dev branch

        ![Create-MR-Branch](../assets/create-mr.png){ width="250" }

    1. Open a code editor and checkout the new dev branch
    1. Develop locally using `docker run...`, `docker compose up`, and/or `skaffold dev`
    1. Commit changes and push back to the repo

### Project Init

**The default pipeline file will fail the first time it runs** - it's OK! The first job checks to see if the project has any *project access tokens*, and when it finds that there are none, it runs a job to create one.

### Gather Info

This stage is responsible for analyzing the repository for git tags. It determines if there are any existing tags and - based on the commit messages - whether any tags should be created.

Tag analysis and versioning is automatically semantically versioned using `semantic-release`.

#### Semantic-Release

We use [Semantic Versioning](https://semver.org/) to automatically determine whether a tag is considered "major", "minor", or "patch. [`semantic-release`](https://semantic-release.gitbook.io/semantic-release/) analyzes commit messages and increments versions based on the type of keyword included in a commit message.

To begin using semver tagging in your projects, add any of the following keywords to the beginning of your commit messages:

| **Prefix:** ...commit message...                                           | Release type  |
| ----------------------                                                     | ------------  |
| `fix: ...some smaller bugfix...`                                           | patch         |
| `feat: ...add functionality message...`                                    | minor         |
| `any term!: ...big version change...\nBREAKING CHANGE: some description`*  | major         |
`*` *the "footer" of the commit message must start with **BREAKING CHANGE:***

### Build an Image

This stage uses the in-cluster container builder Kaniko to generate `Docker` compatible images.

### Deploy

This is the stage where the deployment package is updated with the lastest build and applied to the cluster.

![Deploy stage](../assets/deploy-pipeline-generic-steps.png#only-light)
![Deploy stage](../assets/deploy-pipeline-generic-steps-dark.png#only-dark)

This stage has two sub-jobs depending on the target of the commit.

=== "`main` branch"

    Triggers a deployment to `staging` and `production` clusters

    * requires a deployment package with **`staging`** and a **`production`** overlays

=== "any other branch"

    Triggers a deployment "review" to a `development` cluster

    * requires a deployment package with a **`development`** overlay

When the [Default LTC GitLab CI/CD Pipeline](https://issues.ltc.bcit.ca/-/snippets/60) is added to a project, the first run deploys a simple generic deployment package called `generic-dev`. This package is based on an `nginx` deployment and it demonstrates how `kustomize` overlays work.

When you are familiar with the concept of a deployment package and how it is applied by the pipeline, you're ready to learn how to create your own deployment package and configure it to deploy your app.
