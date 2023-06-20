# Getting started

The first step is to create a GitLab project (or clone if one already exists). The project will track changes to your code, store container images, and coordinate the ci/cd pipeline.

## 1. Create a GitLab project

1. Login to [GitLab](https://issues.ltc.bcit.ca) and navigate to the **Apps** group
2. Click the [+] in the top navigation bar
3. Click **Create blank project** to create a new project
4. Give your project a name
5. Select a group, for example ***"web-apps"***, and click the **Create Project** button

!!! note ""

    The LTC also has repositories on other platforms like GitHub ([BCIT-LTC](https://github.com/bcit-ltc)) and BitBucket ([BCIT Bitbucket](https://bcitltc.atlassian.net/), [Bitbucket.org](https://bitbucket.org/)), but GitLab is the on-premise authoritiative source.

## 2. Add the default `deploy/` folder

1. Clone your new project and checkout the `main` branch
2. Copy the [default `deploy/` folder](https://issues.ltc.bcit.ca/ltc-infrastructure/base-packages.git) into the project root (this also contains the default `.gitlab-ci.yml` file).
3. Navigate to the GitLab **Settings > Repository** page and expand the **Push rules** section. There should not be any checkmark next to the *Check whether the commit author is a GitLab user*.
4. Navigate to the GitLab **Settings > CI/CD** page and expand the *General pipelines* section. Add the following to the  **CI/CD configuration file** field:

        deploy/.gitlab-ci.yml

    Click the **Save changes** button.

5. Commit and push the changes

When a `deploy/` folder is added to the project, GitLab is configured to trigger a pipeline; a push to the project repo triggers the pipeline, which runs jobs to check the source code version, build an app image, and deploy the image to a Kubernetes cluster.

The first time a pipeline runs, it checks to see if there are any *project access tokens*. When it finds that there are none, a "token creation" pipeline is triggered that creates and stores a new token. This pipeline takes about 5 minutes to finish, and once the project tokens are stored, the project is considered "initialized".

## 3. First code commits

The next stage is to work with the source code to create a `Dockerfile` that builds without errors.

1. Copy your source code into the project

2. Create or edit a `Dockerfile` in the project root that builds an image of your app.

3. Commit and push your code

    !!! failure "If your pipeline fails..."

        Troubleshoot the `Dockerfile` before moving on.
