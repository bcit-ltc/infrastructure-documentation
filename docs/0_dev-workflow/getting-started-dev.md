# Getting Started

Rather than building every functional component into one large monolithic application, our approach is to build smaller apps that have one purpose, and then connect them together with API calls. This makes it easier to update a specific component without having to change to something that already works well.

!!! tip ""

    For example, an authentication component that interfaces with a front-end does not need to be part of the same code base as a data conversion engine that is part of the back-end.

However, this approach presents a challenge for local development unless you can spin up an environment that has all the components needed to run the app.

Enter Docker.

Docker makes it easier to compartmentalize apps by providing a tool stack that builds and runs standardized "images" - small containers of executable code that can be deployed on any platform.

Docker also helps avoid deployment trouble because of a mismatch between a local dev environment and the deployment server environment.


## Requirements

To get started, download and install the following:

- [Docker desktop](https://www.docker.com/products/docker-desktop)


## Workflow

A typical "dev loop" involves committing code, building an image, running tests, and deploying the image to a registry.

![Development Loop](../assets/dev-loop.png)
 
We use Docker to:

- develop locally using the `docker compose` command
- build a development image 
- push the image to the LTC private registry

Once an image is stored in the registry it can be deployed as a ***release*** on the Kubernetes cluster.


### Repository structure

For us, a pattern has emerged that is loosely based on GitFlow:

- `feature` branches are forked from a `main` branch and merged after code review and approval
- `main` branch code is built and deployed to the `staging` cluster
- a `merge request`is pulled into a `release` branch, which gets tested, approved, and deployed to the `prod` cluster

![versioning workflow](../assets/git-workflow-simple.png#only-light)
![versioning workflow](../assets/git-workflow-simple-dark.png#only-dark)

This workflow generally involves the following steps:

1. Creating or cloning a project
1. Creating an Issue
1. Creating a Merge Request and Branch
1. Checking out the branch locally
1. Running Docker to create a dev environment
1. Programming with a single purpose - see [separation of concerns](https://nalexn.github.io/separation-of-concerns/)
1. Committing with descriptive messaging
1. Building an image
1. Pushing the image to the project registry
1. Requesting a code review
1. Approved Merge Requests trigger a CI/CD pipeline that deploys a workload to a cluster


### Using Docker

Docker can be used in a few different ways. A nice way to try out an app is to run it using `docker` instead of installing it.

!!! example "Running nginx using Docker"

    1. Start Docker
    1. Open a terminal and run `docker container run -p 8080:80 nginx`
    1. Open a browser and navigate to `localhost:8080`


#### `docker compose`

When building single-purpose apps and connecting them in a "microservice" pattern, `docker compose` helps by creating a local dev environment that simulates the connected components that run in production.

See [Docker Compose File Basics](https://takacsmark.com/docker-compose-tutorial-beginners-by-example-basics/#compose-file-basics) for a good overview of how `docker-compose.yml` files work.


!!! example "Example postgres `stack.yml` for `docker compose`"

    ```
    # Use postgres/example user/password credentials
    version: '3.1'

    services:

      db:
        image: postgres
        restart: always
        environment:
          POSTGRES_PASSWORD: example

      adminer:
        image: adminer
        restart: always
        ports:
          - 8080:8080
    ```

`docker compose` files are pretty unique, but a few examples can be found in the `Templates`>`docker compose examples` project.


## Building Images

When you are ready to build an image and push it to a registry, navigate to the GitLab project page and look for the `Packages and Registries` menu link. Click on `Container Registry` and look for the CLI commands to login to the registry, build (and tag) the image, and push it.

!!! example "Example CLI commands"

    `$ docker login registry.dev.ltc.bcit.ca`

    `$ docker build -t registry.dev.ltc.bcit.ca/web-apps/qcon/qcon-api .`

    `$ docker push registry.dev.ltc.bcit.ca/web-apps/qcon/qcon-api`

Now that you have an image in a registry, it can be deployed to a Kubernetes cluster as a workload.