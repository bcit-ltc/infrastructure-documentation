# CI/CD Pipeline Details

!!! warning "Under Construction"

    This page is still being written...

"The pipeline" is actually several pipelines working in different projects. As much as possible, the pipelines have been created to perform a discrete function. These include:

* Coordinating the deployment of source code to a `dev` cluster for review
* Creating a *deployment package* project
* Creating a project access token
* Creating a deployment trigger token
* Writing access configuration to Vault
* Coordinating the deployment of source code to `staging` and `production` clusters

## `LTC Infrastructure` > `Project Init`

## `Deployments` > `CI Config`
