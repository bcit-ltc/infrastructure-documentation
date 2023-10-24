# Getting started

The first step is to create a GitLab project (or clone if one already exists). The project will track changes to your code, store container images, and coordinate the ci/cd pipeline.

## 1. Create a GitLab project

1. Login to [GitLab](https://issues.ltc.bcit.ca) and navigate to the **Apps** group

1. Click the [+] in the top navigation bar

1. Click **Create blank project** to create a new project

1. Give your project a name

1. Select a group, for example ***"web-apps"***, and click the **Create Project** button

!!! note ""

    The LTC also has repositories on other platforms like GitHub ([BCIT-LTC](https://github.com/bcit-ltc)) and BitBucket ([BCIT Bitbucket](https://bcitltc.atlassian.net/), [Bitbucket.org](https://bitbucket.org/)), but GitLab is the on-premise authoritiative source.

## 2. Add the default `deploy/` folder

1. Clone your new project and checkout the `main` branch

1. Copy the [default `deploy/` folder](https://issues.ltc.bcit.ca/web-apps/generic-dev/-/tree/main) into the project root (this also contains the default `.gitlab-ci.yml` file).

1. Navigate to the GitLab **Settings > Repository** page and expand the **Push rules** section.

    - Uncheck any checkmark next to the *Check whether the commit author is a GitLab user*.

1. Navigate to the GitLab **Settings > CI/CD** page and expand the *General pipelines* section.

    - Uncheck "Public pipelines"
    - Add the following to the  **CI/CD configuration file** field:

            deploy/.gitlab-ci.yml

    Click the **Save changes** button.

1. Commit and push the changes

When a `deploy/` folder is added to the project, GitLab is configured to trigger a pipeline; a push to the project repo triggers the pipeline, which runs jobs to check the source code version, build an app image, and deploy the image to a Kubernetes cluster.

!!! note ""

    The first time a pipeline runs, it checks to see if there are any *project access tokens*. When it finds that there are none, it will fail. We are in the process of creating a "token creation" pipeline that creates and stores a new tokens, but until this is finished, token creation must be done manually.

    Once the project tokens are created and stored in Vault, the project is considered "initialized".

## Next steps

After creating a project, browse the documentation on the following topics:

- [development workflow](./development-workflow.md)
- [routes/endpoints](./routes-endpoints.md)
- [secrets](./secrets.md)
- [semantic-versioning](./semantic-versioning.md)
- [continuous deployment overview](./continuous-deployment-overview.md)
- [initializing for `latest` and `stable` deployments](../infrastructure-details/initializing-latest-stable.md)
