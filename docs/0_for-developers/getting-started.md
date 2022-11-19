# Getting started

The first step is to create a GitLab project to store your code. This project will track changes to your code, store project images, and coordinate the ci/cd pipeline.

!!! warning "Requirements"

    This page assumes some working knowledge of the following:

    * Git
    * Docker
    * Basic CI/CD concepts (jobs, environments)
    * Basic Kubernetes concepts (deployments, services, ingresses)

    See the [tech stack documentation](../2_tech-stack-documentation/index.md) for LTC-curated resources or see the respective technology's documentation.

## Create a GitLab project

GitLab is the centralized platform for the LTC's source code.

1. Login to [GitLab](https://issues.ltc.bcit.ca) and navigate to the **Apps** group
1. Click the [+] in the top navigation bar
1. Click **Create blank project** to create a new project
1. Give your project a name, pick a group like **(web-)apps**, and click the "Create Project" button

The LTC has repositories on other platforms like GitHub ([BCIT-LTC](https://github.com/bcit-ltc)) and BitBucket ([BCIT Bitbucket](https://bcitltc.atlassian.com), Bitbucket.com), but GitLab is considered the authoritiative source.

## Add the default ci/cd pipeline

1. Clone your project and checkout the `main` branch
1. Copy the [default LTC GitLab ci/cd pipeline file](https://issues.ltc.bcit.ca/-/snippets/60) into the project root with the name `.gitlab-ci.yml`
1. Edit the `.gitlab-ci.yml` file by updating the cluster you will be deploying to:

    1. look for the **Pipeline configuration** section close to the bottom
    1. change the **CLUSTER_NAME** to either `dev-cp` or `dev-vsm`

            ...
            ##---------- Pipeline configuration ----------
            #
            #
            variables:                               # other global variables are set in GitLab Admin
              CLUSTER_NAME: {--dev-cp--} {++dev-vsm++}           # options: dev-cp, dev-vsm
            ...

1. Commit and push the changes

!!! warning "Initial run"

    When a `.gitlab-ci.yml` file is added to the project, the pipeline checks to see if there are any *project access tokens*, and when it finds that there are none, it will fail. **That's OK!** This failure triggers a different pipeline to create a new token and store it in Vault.

    **The initial run takes about 5 minutes before the token is ready to use.**

## First code commit

Now that the project has been *initialized*, it's ready for source code.

1. Copy your source code into the project

    !!! warning "`Dockerfile` Requirement"

        A working `Dockerfile` is required.

1. Commit and push your code

    !!! failure "If your pipeline fails..."

        Troubleshoot the `Dockerfile` before moving on.

## Development workflow

We adopted a workflow pattern that is loosely based on [GitLab Flow](https://docs.gitlab.com/ee/topics/gitlab_flow.html). Projects have a persistent **`main`** branch, and new bugfixes or features are added to ephemeral **`feat/`** or **`fix/`** branches.

Feature and fix branch code is deployed to a `dev` cluster and `main` branch code is deployed to the `staging` and `production` clusters.

![deployment workflow](../assets/deployment-workflow-simple-light.png#only-light)
![deployment workflow](../assets/deployment-workflow-simple-dark.png#only-dark)

This workflow helps us keep track of bugfixes, new features, and major changes without complex branching.

!!! example "Development workflow"

    ![versioning workflow](../assets/git-workflow-simple-light.png#only-light)
    ![versioning workflow](../assets/git-workflow-simple-dark.png#only-dark)

    After cloning a project repository:

    1. **Create an Issue, a Merge Request (MR), and new branch for development**

        1. Create an Issue (eg. `updates README with project description`)
        1. Create a Merge Request (MR) and a new branch

            ![Create-MR-Branch](../assets/create-mr.png)

    1. **Checkout the new branch, develop, commit, and sync**
        
        Pushing your code triggers a pipeline run. The pipeline:
        
        1. Builds an image
        1. Pushes the image to the project registry
        1. Deploys the workload to a **`dev`** cluster

    1. **Request a code review and approval**
    1. **Merge the branch into `main`**
    
        Merging a development branch into **`main`** triggers a pipeline run that:

        1. Builds an image tagged with the label `latest`
        1. Pushes the image to the project registry
        1. Deploys the workload to the *staging* cluster

            **Commits that have a commit message that starts with a semantic versioning keyword will automatically increment the version tag of the repo and deploy the workload to the *production* cluster.**

### Semantic versioning

The pipeline uses [`semantic-release`](https://semantic-release.gitbook.io/semantic-release/) to analyze commit messages and determine if a new tag should be created.

To use automatic [semver tagging](https://semver.org/), add any of the following to your commit messages:

| **Prefix:** ...commit message...                                           | Release type  |
| ----------------------                                                     | ------------  |
| `fix: ...some smaller bugfix...`                                           | patch         |
| `feat: ...add functionality message...`                                    | minor         |
| `any term!: ...big version change...\nBREAKING CHANGE: some description`*  | major         |
`*` *the "footer" of the commit message must start with **BREAKING CHANGE:***

## First deployment

When the default pipeline runs for the first time, it simply prints out a message:

    GENERIC_DEPLOYMENT is set.

    #####
    ##### Generic packages are not deployed to staging/production.
    #####
    #####   - Deploying to staging or production requires a deployment package with working staging and production overlays.
    #####   - Set DEPLOY_PKG_INIT="true" in your pipeline file to create a generic package. Then
    #####     clone the deployment package and configure it for staging/production.
    #####
    ##### See https://infrastructure-documentation.ltc.bcit.ca/ for more info.
    #####

If we see this message, the pipeline is configured correctly! It confirms that the `Dockerfile` can be built successfully, that the integration between GitLab and Vault is configured correctly, and that a **GENERIC_DEPLOYMENT** is configured.

Out-of-the-box, the pipeline only deploys a generic deployment package from a `dev` branch to verify that things are configured correctly. After we replace the generic package with a package specific to our project, we'll be able to deploy code from the `main` branch.

To verify that GitLab can deploy to Kubernetes, create a branch and commit to that branch:

1. Create an Issue (eg. `updates README with project description`)
1. Create a Merge Request (MR) and a new branch

    ![Create-MR-Branch](../assets/create-mr.png)

1. Open a code editor and checkout the new branch
1. Add/replace content in `README.md` that describes the project
1. Commit the changes and push to the repo

The push triggers the pipeline to run; if you look at the **CI/CD > Pipelines** page you should see the pipeline's progress.

Commits to a branch other than `main` trigger a deployment to the Kubernetes cluster specified in the `.gitlab-ci.yml` file. The default *generic deployment package* is a simple `nginx` workload that confirms that the GitLab can deploy to Kubernetes.

To confirm that GitLab can deploy to Kubernetes:

1. Look at the top of your GitLab MR:

    ![gitlab merge request](../assets/gitlab-mr-light.png)

1. Click the **View App** button to navigate to the deployment

If you see something like this, you've successfully deployed a workload to Kubernetes!

![generic-dev nginx workload](../assets/nginx-generic-dev-light.png#only-light)
![generic-dev nginx workload](../assets/nginx-generic-dev-dark.png#only-dark)
