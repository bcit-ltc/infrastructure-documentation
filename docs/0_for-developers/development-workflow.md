---
title: Workflow
---

# Development Workflow

The workflow is loosely based on [GitLab Flow](https://docs.gitlab.com/ee/topics/gitlab_flow.html) where projects have a persistent **`main`** branch, and new bugfixes or features are added to ephemeral **`feature`** or **`fix`** branches.

`feature` and `fix` branch code is deployed to a `review` cluster and `main` branch (default) code is deployed to the `latest` and `stable` clusters.

![deployment workflow](../assets/deployment-workflow-simple-light.png#only-light)
![deployment workflow](../assets/deployment-workflow-simple-dark.png#only-dark)

This workflow helps us keep track of bugfixes, new features, and major changes without complex branching.

!!! example "Development workflow"

    ![versioning workflow](../assets/git-workflow-simple-light.png#only-light)
    ![versioning workflow](../assets/git-workflow-simple-dark.png#only-dark)

    After cloning a project repository:

    1. **Create an Issue, a Merge Request (MR), and new branch for development**

        1. Create an Issue

                for example: `updates README with project description`

        2. Create a Merge Request (MR) and a new branch

            ![Create-MR-Branch](../assets/create-mr.png)

    2. **Checkout the new branch, develop, commit, and push**
        
        Pushing your code triggers a pipeline run. The pipeline:
        
        1. Builds an image
        2. Pushes the image to the project registry
        3. Deploys the workload to a cluster for **`review`**

    3. When you are satisfied with your work, **request a code review and approval**
    4. **Merge your work into the `main` branch**

!!! note "Viewing the workloads"

    * Commits to the **`main`** branch trigger a pipeline that deploys the workload to the **`latest`** cluster
    * Commits with a **git tag** trigger a deployment to the **`stable`** cluster.
    * Commits on a branch other than `main` trigger a deployment to the **`review`** cluster.

    To automatically analyze and add git tags, include a semantic versioning keyword in your commit message. See [semantic-versioning](./semantic-versioning.md) for more info. 
