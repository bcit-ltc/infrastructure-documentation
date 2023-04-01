# Routes/Endpoints

The permalinks used by the ingress resources follow a predictable pattern:

| Branch                | URL                                                     | Notes           |
| --------------------- | ------------------------------------------------------  | --------------- |
| development branches  | `https://review.ltc.bcit.ca/{projectName}/{branchName}` | Review cluster  |
| `main`                | `https://latest.ltc.bcit.ca/{projectName}`              | Latest cluster  |
| `main` + `git tag`    | `https://stable.ltc.bcit.ca/{projectName}`              | Stable cluster  |


!!! note "Custom Project URL"

    To configure a memorable URL for your app, setup an additional *public endpoint* ingress by configuring the `public-endpoint.yaml` file in `overlays` > `stable`.

    | Branch             | URL                                  | Notes                      |
    | ------------------ | ------------------------------------ | -------------------------- |
    | `main` + `git tag` | `https://{projectName}.ltc.bcit.ca/` | Public endpoint (optional) |

