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

This project houses common pipelines called whenever init tasks are needed. The pipeline configuration files exist on different branches.

### `deploy-pkg-init` pipeline

1. Parse trigger payload
1. Create deploy package
    * create "create deploy-package-project" payload
    * create project
1. Trigger the `project-token-init` pipeline (Deployments/CI_Config project)

### `create-project-token` pipeline

1. Parse trigger payload
1. Create project token
    * create payload for token creation
    * create token
    * retrieve vault userpass auth token to write secrets
    * writes token as a vault secret
1. Trigger the `commit-vault-config` pipeline

### `commit-vault-config` pipeline

1. Parse trigger payload
1. Create role files
    * create gitlab-jwt role file
    * create kubernetes-auth role file
1. Commit Terraform files for Vault roles
    * create branch for the commit
    * create commit payload
    * commit payload to the branch
    * create a merge request payload
    * create a merge request (MR)
    * check if branch can be merged
    * create merge payload to approve and delete branch
    * merge the MR

## `create-deploy-trigger-token` pipeline

1. Parse trigger payload
1. Create trigger token
    * check if trigger token already exists
    * create trigger token
1. Write secret to Vault
    * retrieve vault userpass auth token to write secrets
    * retrieve existing `-deployabot` secret
    * inject trigger token into existing `-deployabot` secret
    * write updated secret to Vault

## `Deployments` > `CI Config`

This repo houses the common deployment helper scripts for ci/cd pipelines.

### `build.yml`

Main configuration file for building images using Kanko.

#### `.build_image` job

* Set image labels
* Reformat Docker tags to Kaniko's `--destination` argument
* Execute the build

### `deploy.yml`

Main configuration file for deploying review images to `dev` Kubernetes clusters and triggering deployments/releases to `staging` and `production` Kubernetes clusters.

#### `.deploy_review` job

Metajob that deploys a workload from the `dev` overlay of a deployment package to a `dev` cluster.

* Apply overrides for generic deployment and production namespaces
* Retrieve vault token and generate certs for remote Docker calls
* Get the deployment package
* Set namespace annotations to place workload in the correct Rancher project
* Hydrate the package
* Determine if the package already exists on the cluster
* Apply kustomized changes to the cluster

#### `.undeploy_review` job

* Apply overrides for generic deployment and production namespaces
* Get the deployment package
* Determine if package already exists on the cluster
* Remove kustomized changes to cluster

#### `.deploy` job

Trigger a deployment/release pipeline (`.gitlab-ci.yml` in the deployment package).

* Apply production namespace override
* Trigger the deployment package pipeline

### `git-info.yml`

Analyzes repo for existing tags and generates new semver tags if a commit message has a `Semantic-Release` [(Angular formatted](https://github.com/angular/angular/blob/master/CONTRIBUTING.md#commit) keyword.

#### `.get_info` job

* Run semantic-release if the branch is main ("latest" or "stable")
* Determine if repo has tags
* Store tags in `tags.env` for later jobs

### `parse.yml`

#### `.parse-pipeline-trigger-payload` job

* Parse pipeline trigger payload and store env vars in `trigger_info.env`

#### `.parse-commit` job

* Parse commit message to determine TARGET_ENV
* Store TARGET_ENV in `target.env` for later jobs

### `project-init.yml`

Coordinator job to initialize a project with a project access token and, optionally, a deployment package. Also configures environment variables for later jobs.

#### `.project_init` job

* Set defaults and check if group root is "deployments"
* Check for existing project access tokens
* Check if the deployment package project already exists
* Check if the deployment package has a pipeline triger token
* Trigger `create-project-token` pipeline
* Trigger `deploy-pkg-init` pipeline
* Trigger `create-deploy-trigger-token` pipeline
* Store GitLab group name in `deploy-pkg-group.env` for later (hydration) jobs

### `release.yml`

Job that configures TLS and applies kustomized resources to a cluster.

#### `.release-deployment` job

* Apply a release to a cluster if TARGET_ENV is set

### `update-packages.yml`

Metajob that creates a working copy of the deployment package, applies the latest environment variables (eg. GIT_TAG, IMAGE_NAME, etc...), and commits the changes to trigger a deployment pipeline.

#### `.update-packages` job

* Set kubernetes context and set the displayed user with the commits that are about to be made
* Retrieve vault token and generate certs for remote Docker calls
* Clone the repository inside a new working copy
* Set namespace annotations to place workload in the correct Rancher project
* Hydrate the package
* Determine if the package already exists on the cluster
* Check if there are changes to commit

### Other "common" script files

#### `.deploy-hydrate.yml`

##### `.generic-deployment` job

Override for projects without a deployment package.

* Override with `generic-dev` deployment package if GENERIC_DEPLOYMENT is set

##### `.common-namespace` job

Override for projects that share a common namespace.

* Override with production namespace if COMMON_NAMESPACE is set

##### `.retrieve-package` job

Retrieves the deployment package.

* Pull latest deployment package

##### `.add-rancher-project-annotations` job

Set namespace annotations to place workload in the correct Rancher project.

* Add Rancher ProjectID's based on DEPLOY_PKG_GROUP

##### `.hydrate-package` job

Hydrate deployment package with updated version, image ref, namespace, and host values.

* Hydrate packages with env vars

##### `.check-inventory` job

Check if an inventory resource group already exists in the package or on the cluster.

* Check cluster `resourcegroup` CRD and deployment package `Kptfile` for inventory

#### `.rules.yml`

Rules included in various jobs to limit when a job is added to a pipeline.

* `.deploy_review_rules`
* `.undeploy_review_rules`
* `.deploy_staging_rules`
* `.deploy_prod_rules`
* `.pipeline_trigger_rules`
* `.deployment_rules`
* `.build_image_rules`

#### `.vault.yml`

Vault-specific scripts to retrieve a write-capable token and generate certificates.

#### `.get-vault-token` job

* Get token from Vault using userpass auth method

#### `.get-vault-certs` job

* Generate short TTL certificates to secure communication
* Move certs into place for remote Docker calls
