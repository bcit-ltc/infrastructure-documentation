# LTC Infrastructure Documentation

Information about the architecture and makeup of the LTC's server infrastructure.

## Developing

### Using Codespaces

1. Create an issue & branch for your work
1. [Open repo in Codespaces](https://codespaces.new/bcit-ltc/infrastructure-documentation) and checkout your branch
1. Open a terminal and run

    direnv allow
    docker compose up

1. Browse to `http://localhost:8080` (for browser-based sessions: command palette: `>open port in browser`).

### Using your own environment

#### Dependencies

For basic local development:

- set "APP_NAME" environment variable
- `docker` or `buildah`

To test cluster deployment:

- `direnv`
- `kubectl`
- `helm`
- `k3d`
- `skaffold`

### Other tools in this devcontainer

- `dagger`
- `nix`

### Testing cluster deployment

1. Run `make cluster` (and optionally, `make dashboard` for the [Kubernetes-dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) app), followed by `skaffold dev`

### Cleanup

To remove all cluster resources, run `make delete`.

## License

Mozilla Public License 2.0

## About

Developed in 🇨🇦 Canada at [BCIT's](https://www.bcit.ca/) [Learning and Teaching Centre](https://www.bcit.ca/learning-teaching-centre/). [Contact Us](mailto:courseproduction@bcit.ca).
