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
