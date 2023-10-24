# Routes/Endpoints

The permalinks used by the ingress resources follow a predictable pattern:

| Branch                | URL                                                       | Notes           |
| --------------------- | --------------------------------------------------------- | --------------- |
| feature/fix branches  | `https://review--{branchName}--{projectName}.ltc.bcit.ca/`| `review` cluster  |
| `main`                | `https://latest--{projectName}.ltc.bcit.ca/`              | `latest` cluster  |
| `main` + `git tag`    | `https://{projectName}.ltc.bcit.ca/`                      | `stable` cluster  |
