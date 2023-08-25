# Pipeline details

When the default pipeline runs for the first time, it initializes the project by connecting GitLab to systems like [Vault](https://vault.ltc.bcit.ca/) and [Kubernetes](https://rancher2.ltc.bcit.ca). If you navigate to the GitLab `CI/CD > Pipelines` page you can monitor the status of pipelines.

The default pipeline has a couple of *stages*, and each stage has one or more **jobs**. Click on an icon in the stages column to see the status of individual jobs.

Any commit to the `main` branch of a project with a pipeline configuration file will trigger the pipeline. The pipeline:

1. Checks whether the project has existing Git Tags, or whether a new semantic version should be created
2. Builds an image of the application
3. Deploys an image of the app to a Kubernetes cluster

## Pipeline requirements

* `Dockerfile` that builds successfully
* `deploy/` folder with Kubernetes configuration manifests
* `.gitlab-ci.yml` file

The default `deploy/` folder contains a configuration file that deploys a generic workload so that the basic connections between systems can be verified. After we replace the generic workload with our own project's information we'll be able to deploy our app.

## First deployment

!!! note

    Make sure to add a `deploy/` folder to your main branch before going further

To verify that GitLab can deploy to Kubernetes, create a `feature` or `fix` development branch and make a commit to that branch:

1. Create an Issue (eg. `updates README with project description`)
2. Create a Merge Request (MR) and a new branch

    ![Create-MR-Branch](../assets/create-mr.png)

3. Open a code editor and checkout the new branch
4. Add/replace content in the `README.md` to describe the project
5. Commit the changes and push to the repo

The push triggers a pipeline that deploys the work in your branch to a cluster for `review`. If you look at the **CI/CD > Pipelines** page you should see the pipeline's progress.

!!! note "`review` deployments"

    Commits to a branch other than `main` trigger a deployment to the **review** Kubernetes cluster.
    
    The default *generic deployment package* is a simple `nginx` workload that confirms that the GitLab can deploy to Kubernetes.

    To confirm this:

    1. Look at the top of your GitLab MR:

        ![gitlab merge request](../assets/gitlab-mr-light.png)

    1. Click the **View App** button to navigate to the deployment

    If you see something like this, the generic deployment has been successfully deployed to Kubernetes!

    ![generic-dev nginx workload](../assets/nginx-generic-dev-light.png#only-light)
    ![generic-dev nginx workload](../assets/nginx-generic-dev-dark.png#only-dark)
