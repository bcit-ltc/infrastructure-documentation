# Services


## GitLab

GitLab is the LTC's code repository and container registry. It is also used as an issue tracker and comes with a built-in version of [Mattermost](https://mattermost.com/) for `Slack`-style team communication.

* As a member of the `LTC Users` Active Directory group, access the site at [https://issues.ltc.bcit.ca](https://issues.ltc.bcit.ca). This site currently does not require VPN.


## Vault (https://vault.ltc.bcit.ca:8200)

[Hashicorp Vault](https://vault.ltc.bcit.ca:8200) is the LTC's secrets management platform. It stores secrets used for apps, database credentials, certificates, and more, and serves as an authentication middleware to secure communication between source code repositories, and a deployment endpoint in our Kubernetes clusters.

* Access the site at [https://vault.ltc.bcit.ca:8200](https://vault.ltc.bcit.ca:8200) while connected to VPN. Login with your BCIT credentials using the **LDAP** authentication method.


## Rancher

Rancher is an easy-to-use GUI for Kubernetes. It helps us manage and get insight into the processes, services, and statuses of our clusters.

* Visit [https://rancher2.ltc.bcit.ca](https://rancher2.ltc.bcit.ca) while connected to VPN.


## Mattermost

Mattermost is an open-source chat service that emulates the functionality of Slack. Mattermost comes bundled with GitLab and we use it for bantering and sharing ideas.

* Login with your GitLab credentials at [https://mattermost.ltc.bcit.ca](https://mattermost.ltc.bcit.ca).