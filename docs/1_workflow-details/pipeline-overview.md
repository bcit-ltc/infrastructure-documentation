# CI/CD Pipelines

A CI/CD pipeline is an infrastructure function that watches repositories for changes and then performs actions when a new commit is pushed. Our CI/CD pipelines build images and deploy them to a cluster.

!!! note "CI/CD Pipeline"

    CI/CD stands for **continuous integration/continuous deployment**, and it refers to an integration between the code base and the deployment environment.

A CI/CD pipeline is a set of `jobs` that are configured to run automatically every time a new commit is pushed to a repository. These jobs can do many things, including testing code, building images, and pushing a deployment to a cluster. Examples of popular CI/CD pipeline tools are Drone, CircleCI, and TravisCI.

GitLab comes with a built-in CI/CD sub-system; it relies on a **runner** and a `.gitlab-ci.yml` configuration file.

A commit to a repo configured with a `.gitlab-ci.yml` file triggers a pipeline that builds the app and then deploys it to a cluster.

![Deployment Pipeline](../assets/deploy-pipeline-overview-light.png#only-light)
![Deployment Pipeline](../assets/deploy-pipeline-overview-dark.png#only-dark)

!!! warning "Requirements"

    1. `Dockerfile` - the configuration file that tells the system how to build an image of your app
    1. `.gitlab-ci.yml` file

    The [default GitLab ci/cd pipeline](https://issues.ltc.bcit.ca/-/snippets/60) file can be added to any project with a `Dockerfile` to get started.

## Stages

The default LTC pipeline has the following stages:

1. project init
1. gather info
1. build
1. deploy

Pushing a commit triggers the pipeline to run through each of these stages.

!!! example "Working with a CI/CD Pipeline"

    1. Create an Issue
    1. Create a Merge Request and a new branch for development

        ![Create-MR-Branch](../assets/create-mr.png){ width="250" }

    1. Open a code editor and checkout the new branch
    1. Develop locally using `docker run...`, `docker compose up`, and/or `skaffold dev`
    1. Commit and push changes to the remote

### Project init

`Project init` checks to see if the project has any *project access tokens*, any deployment packages, and any deployment package trigger tokens. If it finds that any of these are missing, it creates them.

### Gather info

This stage analyzes the repository for git tags. It determines if there are any existing tags and whether any tags should be created. Tag analysis and creation is automatically handled using `semantic-release`.

#### Semantic-Release

We use [Semantic Versioning](https://semver.org/) to determine whether a commit should be tagged. [`semantic-release`](https://semantic-release.gitbook.io/semantic-release/) analyzes commit messages and increments versions based on the type of keyword included in a commit message.

To use automatic semver tagging, add any of the following keywords to the beginning of your commit messages:

| **Prefix:** ...commit message...                                           | Release type  |
| ----------------------                                                     | ------------  |
| `fix: ...some smaller bugfix...`                                           | patch         |
| `feat: ...add functionality message...`                                    | minor         |
| `any term!: ...big version change...\nBREAKING CHANGE: some description`*  | major         |
`*` *the "footer" of the commit message must start with **BREAKING CHANGE:***

### Build

This stage builds an image using the in-cluster container builder, Kaniko. The image is then pushed to the project's container registry.

### Deploy

This is the stage where the deployment package is updated with the lastest build information (image tag) and applied to the cluster.

![Deploy stage](../assets/deploy-pipeline-details-light.png#only-light)
![Deploy stage](../assets/deploy-pipeline-details-dark.png#only-dark)

This stage has two jobs depending on the target of the commit.

=== "`main` branch"

    Triggers a deployment to the `staging` cluster, and the `production` cluster if the commit has been tagged.

    * requires a deployment package with **`staging`** and a **`production`** overlays

=== "any other branch"

    Triggers a *review* deployment to a `development` cluster

    * requires a deployment package with a **`development`** overlay

When the [default GitLab ci/cd pipeline](https://issues.ltc.bcit.ca/-/snippets/60) is added to a project, the first run deploys a simple generic deployment package called `generic-dev`. This package is based on an `nginx` deployment and it demonstrates how `kustomize` overlays work.
