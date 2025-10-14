# Systems and Services

The LTC manages its own systems and services to facilitate the research and development of educational solutions. We are careful about how we "operationalize" a system or service. Regardless of an application's audience or purpose, we adhere to the guidelines outlined in [Policy 3501: Acceptable Use of Information Technology](https://www.bcit.ca/files/pdf/policies/3501.pdf).

!!! warning "Access Requirements"

    Most systems and services have some basic access requirements:
    
    * Install and run a BCIT VPN solution
    * Membership in the `LTC Users` Active Directory group. If you're not part of that group and you need access, please [submit a request to the ITS TechHelp desk](https://techhelp.bcit.ca/).

## GitHub

> [https://github.com/bcit-ltc](https://github.com/bcit-ltc)

GitHub is the LTC's code repository, CI/CD pipeline coordinator, and package registry. It is also used as an issue tracker and comes with a built-in project management tool.

Use GitHub to:

* record work using version controlled source code repositories
* track issues related to projects
* run CI/CD pipelines that automate building and deploying
* store images in the package registry

??? note "Starting a project"

    Start a project by creating a code repository in GitHub. Give your project a description and add a README.md to help the community understand what the project is and how they can start using it.

## Vault

> [https://vault.ltc.bcit.ca:8200](https://vault.ltc.bcit.ca:8200)
>
> * Login with your BCIT credentials using the **OIDC** authentication method

[Hashicorp Vault](https://vaultproject.io) is the LTC's secrets management platform. It stores secrets used for apps, database credentials, certificates, etc..., and serves as an authentication middleware to secure communication between source code repositories and deployments.

## Rancher

> [https://rancher3.ltc.bcit.ca](https://rancher3.ltc.bcit.ca)
>
> * Login with your BCIT credentials

We use Kubernetes to deliver our apps and services and Rancher is an easy-to-use UI for Kubernetes. Rancher helps us manage the workloads and services on our clusters.
