# Deployment Package Changes

Based on feedback about how complicated it is to maintain separate app source code and deployment package projects, we've been looking at ways to make it easier to control everything all in one place. We're excited to announce that it's now possible to include all the deployment configuration files in the app source code project!

This means it's easier to track current deployment image tags, create deployment configurations, and understand your project's current status.

## Embedded `deploy/` deployment configuration

Now, by copying the **generic deploy folder** into your project and making a small change to the default `.gitlab-ci.yml` pipeline location, all your app's deployment configuration can be embedded directly in the source code project.

```
    |
    |- project root/
        |
        |- deploy/
            |- base/
            |- overlays
                |
                |- latest
                |- review
                |- ...
    |
    |- app/
        |
        |- source/
        |- ...
    |- package.json
    |- README.md
    |- ...
```

## Deprecating `deployments/`

This also means there's no longer a need to maintain the deployment packages in the GitLab `Deployments` group. This group and the projects that are under **this group will be deprecated and removed on July 6, 2023**.