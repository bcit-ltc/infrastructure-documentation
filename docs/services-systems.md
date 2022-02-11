# Services and Systems

The LTC operates systems and services based on ITS-provisioned virtual machines so that we have the flexibility to research and develop educational solutions that are not typically bound by "enterprise", or "corporate" operational policies. With this flexibility comes responsibility, so we are careful about how we "operationalize" a system or service. Regardless of the application's audience or purpose, we adhere to and promote the guidelines outlined in [Policy 3501: Acceptable Use of Information Technology](https://www.bcit.ca/files/pdf/policies/3501.pdf).

!!! warning "Access Requirements"

    Most systems and services require that you are part of the `LTC Users` Active Directory group. If you're not part of that group, please submit a request to ITS.


## GitLab
> [https://issues.ltc.bcit.ca](https://issues.ltc.bcit.ca)

GitLab is the LTC's code repository, CI/CD pipeline coordinator, and container registry. It is also used as an issue tracker and comes with a built-in version of [Mattermost](https://mattermost.com/) for chat-style team communication.

We use GitLab to:

* record our work on projects through the version control system
* track issues related to projects
* run CI/CD pipelines that automate building and deploying
* save copies of images in each project's private image registry

!!! note "Starting a project"

    We usually start a project by creating a code repository in GitLab in one of these "top-level" groups:

    `Web Apps`
    :   Mature web applications that have some front-end component

    `VSM Web Apps`
    :   Web applications for the VSM team

    `Utilities`
    :   Tools, resources, and services (both local and server-based) that do not have a front-end

    `LTC Infrastructure`
    :   Infrastructure code to manage the LTC's systems and servers

    `Prototypes`
    :   Sandbox for proof-of-concept (PoC) ideas

    `External`
    :   Projects developed in collaboration with external parties

    There are also `admin` groups for team-specific projects, as well as a `Templates` group that holds projects that we re-use frequently.


## Mattermost
> [https://mattermost.ltc.bcit.ca](https://mattermost.ltc.bcit.ca)
>
> * Login by clicking on the **Login with GitLab** button using your BCIT credentials

Mattermost is an open-source chat service that emulates the functionality of Slack. Mattermost comes bundled with GitLab and we use it for bantering and sharing ideas.


## Vault
> [https://vault.ltc.bcit.ca:8200](https://vault.ltc.bcit.ca:8200)
>
> * vpn required
> * Login with your BCIT credentials using the **LDAP** authentication method.

[Hashicorp Vault](https://vaultproject.io) is the LTC's secrets management platform. It stores secrets used for apps, database credentials, certificates, and more, and serves as an authentication middleware to secure communication between source code repositories, and a deployment endpoint in our Kubernetes clusters.


## Rancher
> [https://rancher2.ltc.bcit.ca](https://rancher2.ltc.bcit.ca)
>
> * vpn required
> * Login with your BCIT credentials

Rancher is an easy-to-use UI for Kubernetes. It helps us manage and get insight into the processes, services, and statuses of our clusters.

We use Kubernetes to deliver our apps and services. See the [Kubernetes section](1_kubernetes/index.md) for more info.


## Legacy Web Servers

Several applications are still served from aging (and bloated) virtual machines; work to migrate these workloads to Kubernetes is ongoing.

**prod1.ltc.bcit.ca**
> [http://ltc.bcit.ca](http://ltc.bcit.ca)

**test1.ltc.bcit.ca**
> [http://test.ltc.bcit.ca](http://test.ltc.bcit.ca)


## Other Systems and Services

Other important services and systems that are used or managed by the LTC include:

* [Teamwork](https://bcit.teamwork.com): A project management platform
* [Desk](https://bcit.teamwork.com/desk/dashboard): A cloud-based email communication platform
* [Kaltura](https://mediaspace.bcit.ca): A video hosting platform
* [Brightspace by D2L](https://learn.bcit.ca): Branded as the *Learning Hub*, an Online course management system
