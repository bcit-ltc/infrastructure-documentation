# Initializing latest and stable

`review` branches are deployed by the GitLab CI/CD pipeline, and `latest` and `stable` workloads are deployed by Flux. This section describes how to initialize a project for `latest` and `stable` deployments.

## Create and store a project access token

> **Note:** This step requires admin access

### Create your own personal access token

1. On gitlab, go to `User Settings` > `Access Tokens`

1. Create a new personal access token with these permissions: `api`, `write_repository`, `write_registry`, `admin_mode`

1. Store your token as it will only show once!

### Create dependabot token

1. Use the curl command below to create a dependabot token. You need `jq` installed for this.

    - `INSERT_PERSONAL_ACCESS_TOKEN_HERE` is your personal access token from above
    - `INSERT_APP_NAME_HERE` is the name of your app
    - `INSERT_PROJECT_ID_HERE` is the gitlab repo project id

            response=$(curl --request POST \
            --header "PRIVATE-TOKEN: INSERT_PERSONAL_ACCESS_TOKEN_HERE" \
            --header "Content-Type: application/json" \
            --data '{ "name": "INSERT_APP_NAME_HERE-dependabot", "scopes": ["api", "write_repository", "write_registry"], "expires_at": "2024-07-01" }' \
            "https://issues.ltc.bcit.ca/api/v4/projects/INSERT_PROJECT_ID_HERE/access_tokens")

            reshaped_response=$(echo $response | jq -c '{
            gitlab: .,
            password: .token,
            username: .name
            }')

            echo $reshaped_response

1. Copy the JSON returned by the command above

### Store the tokens in Vault

1. Go to [https://vault.ltc.bcit.ca:8200/ui/vault/secrets/tokens/list](https://vault.ltc.bcit.ca:8200/ui/vault/secrets/tokens/list) and create a new secret with name `INSERT_APP_NAME_HERE-dependabot` and use the JSON output before as the value.

## Add app authorization config to Vault

Add your application to the [vault-configuration repo](https://issues.ltc.bcit.ca/ltc-infrastructure/vault-configuration).

1. Inside `vault-configuration/gitlab-jwt-auth` folder, copy an existing app `-dependabot.tf` file and replace the project name and `project_id` with your app.

1. Inside `vault-configuration/kubernetes-auth` folder, copy an existing app `-kubeauthbot.tf` file and replace the project name app.

## Add application to Flux Config

Add your application to [flux-config repo](https://issues.ltc.bcit.ca/ltc-infrastructure/flux-config)

1. Copy an existing app folder inside `flux-config/app` and replace all with your app name.

1. Add your app to `flux-config/app/kustomization.yaml`

## Setup GitLab webhooks

Add Flux webhooks to your GitLab project so that Flux can receive notifications when changes are made to the project.

### Latest Webhook

1. Go to [Rancher](https://rancher2.ltc.bcit.ca)

    1. Choose `prod-3` (latest) > `More Resources` > `notification.toolkit.fluxcd.io` > `Receivers`

        - Find your app receiver and copy the hook path: `/hook/random-hash`

    1. Choose `prod-3` (latest) > `Storage` > `Secrets`

        - Find your app webhook and copy the token

1. Create a new webhook either from gitlab project repo or CURL command

    - From gitlab project repo, go to `Settings` > `Webhooks`

        - URL: `https://latest--flux-config.ltc.bcit.ca/hook/INSERT_HOOK_RECEIVER_HASH`
        - Secret token: `INSERT_TOKEN_FROM_STORAGE_SECRETS_WEBHOOK`
        - Trigger: `Push events`, `Tag push events`, `Deployment events`
        - Enable SSL verification

    OR use a CURL command:

        curl --request POST \
            --header "PRIVATE-TOKEN: INSERT_PERSONAL_ACCESS_TOKEN_HERE" \
            --header "Content-Type: application/json" \
            --data '{"url": "https://latest--flux-config.ltc.bcit.ca/hook/INSERT_HOOK_RECEIVER_HASH", "token": "INSERT_TOKEN_FROM_STORAGE_SECRETS_WEBHOOK", "push_events": true, "tag_push_events": true, "deployment_events": true}' \
            "https://issues.ltc.bcit.ca/api/v4/projects/INSERT_PROJECT_ID_HERE/hooks"

### Stable Webhook

1. Go to [Rancher](https://rancher2.ltc.bcit.ca)

    1. Choose `prod-2` (stable) > `More Resources` > `notification.toolkit.fluxcd.io` > `Receivers`

        - Find your app receiver and copy the hook path: `/hook/random-hash`

    1. Choose `prod-2` (stable) > `Storage` > `Secrets`

        - Find your app webhook and copy the token

2. Create a new webhook either from gitlab project repo or CURL command

    - From gitlab project repo, go to `Settings` > `Webhooks`

        - URL: `https://flux-config.ltc.bcit.ca/hook/INSERT_HOOK_RECEIVER_HASH`
        - Secret token: `INSERT_TOKEN_FROM_STORAGE_SECRETS_WEBHOOK`
        - Trigger: `Push events`, `Tag push events`, `Deployment events`
        - Enable SSL verification

    OR use a CURL command:

        curl --request POST \
            --header "PRIVATE-TOKEN: INSERT_PERSONAL_ACCESS_TOKEN_HERE" \
            --header "Content-Type: application/json" \
            --data '{"url": "https://flux-config.ltc.bcit.ca/hook/INSERT_HOOK_RECEIVER_HASH", "token": "INSERT_TOKEN_FROM_STORAGE_SECRETS_WEBHOOK", "push_events": true, "tag_push_events": true, "deployment_events": true}' \
            "https://issues.ltc.bcit.ca/api/v4/projects/INSERT_PROJECT_ID_HERE/hooks"
