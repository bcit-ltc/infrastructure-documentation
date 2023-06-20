# GitLab Restructuring

GitLab-Kubernetes integration is based on an agent-server architecture, where the agent runs on the Kubernetes cluster connected to GitLab.

To minimize the number of agents we must maintain, a proposal is being discussed that re-organizes projects into a smaller number of groups:


![gitlab-re-org](../assets/gitlab-re-org.png)

For more information about the change and the discussion, see [infrastructure-documentation issue#57](https://issues.ltc.bcit.ca/web-apps/infrastructure-documentation/-/issues/57).
