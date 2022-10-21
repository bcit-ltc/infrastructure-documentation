# Code Repositories

!!! tip inline end "LTC Code Repository"

    [https://issues.ltc.bcit.ca](https://issues.ltc.bcit.ca)

    To clone a repo, click the blue "Clone" button at the top right of a project:

    ![gitlab clone](../assets/gitlab-clone.png)

A critical component to the LTC's dev ops workflow is GitLab, which serves to centralize the LTC's source code.

The LTC also has repositories on other platforms like GitHub ([BCIT-LTC](https://github.com/bcit-ltc)) and BitBucket ([BCIT Bitbucket](), Bitbucket.com), but GitLab is considered to be the authoritiative source for the apps that we develop.

In addition to storing source code, GitLab also enables teams to rapidly test and develop their apps through a deployment pipeline that is securely connected with the LTC's Kubernetes clusters.

The CI/CD deployment pipeline and the Kubernetes cluster endpoints are described in other sections.

## Creating a project

A pre-requisite for any development is creating a project to store your source code.

1. Login to [GitLab](https://issues.ltc.bcit.ca) and navigate to the **Apps** group
1. Click the [+] in the top navigation bar to create a new project
1. Name the project, assign it to an appropriate group, and click "Create Project"
1. Open your code editing IDE and clone the project
