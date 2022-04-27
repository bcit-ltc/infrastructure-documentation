# CI/CD Pipeline Overview

!!! warning "Under Construction"

    This page is still being written...

A CI/CD pipeline automatically builds your application and deploys it to a cluster.

## Requirements

1. `Dockerfile` - the configuration file that tells the system how to build an image of your app
1. `.gitlab-ci.yml` file

The [Default LTC GitLab CI/CD Pipeline](https://issues.ltc.bcit.ca/-/snippets/60) file can be added to any project with a Dockerfile to get started.

Once you have the requirements met, commit your files to trigger the pipeline.

## Stages

The default LTC pipeline has the following stages or steps:

1. project initialization
1. gather_info
1. test
1. build
1. deploy

Pushing a commit triggers the pipeline to run through each of these stages.

!!! example "Working with the CI/CD Pipeline"

    1. Create an Issue
    1. Create a Merge Request and a branch

        ![Create-MR-Branch](../assets/create-mr.png)

    1. Open a code editor and checkout the new branch
    1. Develop locally using `docker run...`, `docker compose up`, and/or `skaffold dev`
    1. Commit changes and push back to the repo

## Project Initialization

**The default pipeline file will fail the first time it runs** - it's OK, this is by design! The first job checks to see if the project has any *project access tokens*, and when it finds that there are none, it runs a job that creates one.

## Gather Info

This stage is responsible for analyzing the repository for git tags. It determines if there are any existing tags and - based on the commit messages - whether any tags should be created.

Tag analysis and versioning is automatically semantically versioned using `semantic-release`.

### Semantic-Release

We use [Semantic Versioning](https://semver.org/) to automatically determine whether a tag is considered "major", "minor", or "patch. [`semantic-release`](https://semantic-release.gitbook.io/semantic-release/) analyzes commit messages and increments versions based on the type of keyword included in a commit message.

To begin using semver tagging in your projects, add any of the following keywords to the beginning of your commit messages:

| **Prefix:** ...commit message...                                          | Release type  |
| ----------------------                                                    | ------------  |
| `fix: ...some smaller bugfix...`                                          | patch         |
| `feat: ...add functionality message...`                                   | minor         |
| `any term: ...big version change...\nBREAKING CHANGE: some description`*  | major         |
`*` *the "footer" of the commit message must start with **BREAKING CHANGE:***

## Test

This stage performs basic Static Application Security Testing (SAST). The job scans files of various languages for vulnerabilities and produces a report that suggests potential remediation.

## Build

This stage uses the in-cluster container builder Kaniko to generate `Docker` compatible images.

## Deploy

This stage has two sub-jobs depending on the target of the commit.

=== "`main` (default) branch commits"

    Triggers a deployment to staging and production clusters

    * requires a *deployment package* with staging and a production overlays

=== "commits to any other branch"

    Triggers a deployment "review" to a dev cluster

    * requires a *deployment package with a dev overlay

See the next section for information about how to configure a deployment package.
