# Getting started

The first step is to create a GitLab project (or clone if one already exists). The project will track changes to your code, store container images, and coordinate the ci/cd pipeline.

## 1. Create a GitLab project

1. Login to [GitLab](https://issues.ltc.bcit.ca) and navigate to the **Apps** group
2. Click the [+] in the top navigation bar
3. Click **Create blank project** to create a new project
4. Give your project a name
5. Select a group, for example ***"web-apps"***, and click the **Create Project** button

!!! note ""

    The LTC also has repositories on other platforms like GitHub ([BCIT-LTC](https://github.com/bcit-ltc)) and BitBucket ([BCIT Bitbucket](https://bcitltc.atlassian.net/), [Bitbucket.org](https://bitbucket.org/)), but GitLab is the on-premise authoritiative source.

## 2. Add the default `deploy/` folder

1. Clone your new project and checkout the `main` branch
2. Copy the [default `deploy/` folder](https://issues.ltc.bcit.ca/ltc-infrastructure/base-packages.git) into the project root (this also contains the default `.gitlab-ci.yml` file).
3. Navigate to the GitLab **Settings > Repository** page and expand the **Push rules** section. There should not be any checkmark next to the *Check whether the commit author is a GitLab user*.
4. Navigate to the GitLab **Settings > CI/CD** page and expand the *General pipelines* section. Add the following to the  **CI/CD configuration file** field:

        deploy/.gitlab-ci.yml

    Click the **Save changes** button.

5. Commit and push the changes

When a `deploy/` folder is added to the project, GitLab is configured to trigger a pipeline; a push to the project repo triggers the pipeline, which runs jobs to check the source code version, build an app image, and deploy the image to a Kubernetes cluster.

The first time a pipeline runs, it checks to see if there are any *project access tokens*. When it finds that there are none, a "token creation" pipeline is triggered that creates and stores a new token. This pipeline takes about 5 minutes to finish, and once the project tokens are stored, the project is considered "initialized".

## 3. First code commits

The next stage is to work with the source code to create a `Dockerfile` that builds without errors.

1. Copy your source code into the project

2. Create or edit a `Dockerfile` in the project root that builds an image of your app.

3. Commit and push your code

    !!! failure "If your pipeline fails..."

        Troubleshoot the `Dockerfile` before moving on.


## 4. Create your own personal access token
1. On gitlab, go to `User Settings` > `Access Tokens`
2. Create a new personal access token with these permissions: `api`, `write_repository`, `write_registry`, `sudo`, `admin_mode`
3. Remember your token as it will only show once!


## 5. Create dependabot token
1. Use the curl command below to create a dependabot token. You need `jq` installed for this.
  - `INSERT_PERSONAL_ACCESS_TOKEN_HERE` is your personal access token from step 4
  - `INSERT_APP_NAME_HERE` is the name of your app
  - `INSERT_PROJECT_ID_HERE` is the gitlab repo project id

```
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
```
2. Copy the JSON returned by the command above
3. Go to [https://vault.ltc.bcit.ca:8200/ui/vault/secrets/tokens/list](https://vault.ltc.bcit.ca:8200/ui/vault/secrets/tokens/list) and create a new secret with name `INSERT_APP_NAME_HERE-dependabot` and use the JSON output before as the value

## 6. Add application to Flux Config
1. Add your application to [flux-config repo](https://issues.ltc.bcit.ca/ltc-infrastructure/flux-config)
2. Copy an existing app folder inside `flux-config/app` and replace all with your app name.
3. Add your app to `flux-config/app/kustomization.yaml`


## 7. Add application to Vault repo
1. Add your application to [vault-configuration repo](https://issues.ltc.bcit.ca/ltc-infrastructure/vault-configuration)
2. Inside `vault-configuration/gitlab-jwt-auth` folder, copy an existing app `-dependabot.tf` file and replace the project name and `project_id` with your app.
3. Inside `vault-configuration/kubernetes-auth` folder, copy an existing app `-kubeauthbot.tf` file and replace the project name app.


## 8. Setup Webhook
### Latest Webhook
1. Go to [Rancher](https://rancher2.ltc.bcit.ca)
    a. Choose `prod-3` (latest) > `More Resources` > `notification.toolkit.fluxcd.io` > `Receivers`
        - Find your app receiver and copy the hook path: `/hook/random-hash`
    b. Choose `prod-3` (latest) > `Storage` > `Secrets`
        - - Find your app webhook and copy the token
2. Create a new webhook either from gitlab project repo or CURL command
    * From gitlab project repo, go to `Settings` > `Webhooks`
        - URL: `https://latest--flux-config.ltc.bcit.ca/hook/INSERT_HOOK_RECEIVER_HASH`
        - Secret token: `INSERT_TOKEN_FROM_STORAGE_SECRETS_WEBHOOK`
        - Trigger: `Push events`, `Tag push events`, `Deployment events`
        - Enable SSL verification
    * OR CURL command:
```
curl --request POST \
     --header "PRIVATE-TOKEN: INSERT_PERSONAL_ACCESS_TOKEN_HERE" \
     --header "Content-Type: application/json" \
     --data '{"url": "https://latest--flux-config.ltc.bcit.ca/hook/INSERT_HOOK_RECEIVER_HASH", "token": "INSERT_TOKEN_FROM_STORAGE_SECRETS_WEBHOOK", "push_events": true, "tag_push_events": true, "deployment_events": true}' \
     "https://issues.ltc.bcit.ca/api/v4/projects/INSERT_PROJECT_ID_HERE/hooks"
```

### Stable Webhook
1. Go to [Rancher](https://rancher2.ltc.bcit.ca)
    a. Choose `prod-2` (stable) > `More Resources` > `notification.toolkit.fluxcd.io` > `Receivers`
        - Find your app receiver and copy the hook path: `/hook/random-hash`
    b. Choose `prod-2` (stable) > `Storage` > `Secrets`
        - - Find your app webhook and copy the token
2. Create a new webhook either from gitlab project repo or CURL command
    * From gitlab project repo, go to `Settings` > `Webhooks`
        - URL: `https://flux-config.ltc.bcit.ca/hook/INSERT_HOOK_RECEIVER_HASH`
        - Secret token: `INSERT_TOKEN_FROM_STORAGE_SECRETS_WEBHOOK`
        - Trigger: `Push events`, `Tag push events`, `Deployment events`
        - Enable SSL verification
    * OR CURL command:
```
curl --request POST \
     --header "PRIVATE-TOKEN: INSERT_PERSONAL_ACCESS_TOKEN_HERE" \
     --header "Content-Type: application/json" \
     --data '{"url": "https://flux-config.ltc.bcit.ca/hook/INSERT_HOOK_RECEIVER_HASH", "token": "INSERT_TOKEN_FROM_STORAGE_SECRETS_WEBHOOK", "push_events": true, "tag_push_events": true, "deployment_events": true}' \
     "https://issues.ltc.bcit.ca/api/v4/projects/INSERT_PROJECT_ID_HERE/hooks"
```
