# Getting started

The first step is to create a GitLab project (or clone if one already exists). The project will track changes to your code, store container images, and coordinate the ci/cd pipeline.

## 1. Create a GitLab project

1. Login to [GitLab](https://issues.ltc.bcit.ca) and navigate to the **Apps** group
2. Click the [+] in the top navigation bar
3. Click **Create blank project** to create a new project
4. Give your project a name
5. Select a group, for example **web-apps**, and click the "Create Project" button

!!! note ""

    The LTC also has repositories on other platforms like GitHub ([BCIT-LTC](https://github.com/bcit-ltc)) and BitBucket ([BCIT Bitbucket](https://bcitltc.atlassian.com), Bitbucket.com), but GitLab is the on-premise authoritiative source.

## 2. Add the default ci/cd pipeline

1. Clone your project and checkout the `main` branch
1. Copy the [default LTC GitLab ci/cd pipeline file](https://issues.ltc.bcit.ca/-/snippets/60) into the project root with the name `.gitlab-ci.yml`
2. Commit and push the changes

When a `.gitlab-ci.yml` file is added to the project, the pipeline checks to see if there are any *project access tokens*. When it finds that there are none, a "token creation" pipeline is triggered that creates and stores a new token. This pipeline takes about 5 minutes before the project is ready.

## 3. First code commit

When the `.gitlab-ci.yml` file has been committed, the app project is considered *initialized*. Now it's ready for source code.

1. Copy your source code into the project

    !!! warning "`Dockerfile` Requirement"

        A working `Dockerfile` is required.

2. Commit and push your code

    !!! failure "If your pipeline fails..."

        Troubleshoot the `Dockerfile` before moving on.
