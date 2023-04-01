# Systems and Services

We manage our own systems and services to facilitate the research and development of educational solutions. We are careful about how we "operationalize" a system or service. Regardless of an application's audience or purpose, we adhere to the guidelines outlined in [Policy 3501: Acceptable Use of Information Technology](https://www.bcit.ca/files/pdf/policies/3501.pdf).

!!! warning "Access Requirements"

    Most systems and services have some basic access requirements:
    
    * Install and run BCIT's myVPN
    * Membership in the `LTC Users` Active Directory group. If you're not part of that group and you need access, please [submit a request to the ITS TechHelp desk](https://techhelp.bcit.ca/).


## GitLab

> [https://issues.ltc.bcit.ca](https://issues.ltc.bcit.ca)

GitLab is the LTC's code repository, CI/CD pipeline coordinator, and container registry. It is also used as an issue tracker and comes with a built-in version of [Mattermost](https://mattermost.com/) for chat-style team communication.

Use GitLab to:

* record work using version controlled code repositories
* track issues related to projects
* run CI/CD pipelines that automate building and deploying
* store images in each project's private image registry

??? note "Starting a project"

    Start a project by creating a code repository in GitLab:

    `Apps`
    :   Projects that have some front-end component; UI required.

    `Utilities`
    :   Tools, resources, and services (both local and server-based) that do not have a front-end

## Mattermost

> [https://mattermost.ltc.bcit.ca](https://mattermost.ltc.bcit.ca)
>
> * Login by clicking on the **Login with GitLab** button using your BCIT credentials

Mattermost is an open-source chat service that emulates the functionality of Slack. Mattermost comes bundled with GitLab and we use it for bantering and sharing ideas.

## Vault

> [https://vault.ltc.bcit.ca](https://vault.ltc.bcit.ca)
>
> * Login with your BCIT credentials using the **LDAP** authentication method

[Hashicorp Vault](https://vaultproject.io) is the LTC's secrets management platform. It stores secrets used for apps, database credentials, certificates, etc..., and serves as an authentication middleware to secure communication between source code repositories and deployments.

## Rancher

> [https://rancher2.ltc.bcit.ca](https://rancher2.ltc.bcit.ca)
>
> * Login with your BCIT credentials

We use Kubernetes to deliver our apps and services and Rancher is an easy-to-use UI for Kubernetes. Rancher helps us manage the workloads and services on our clusters.

## Legacy Servers

> **prod1.ltc.bcit.ca**: [http://ltc.bcit.ca](http://ltc.bcit.ca)

Several applications are still served from older virtual machines; work to migrate these workloads to Kubernetes is ongoing.
