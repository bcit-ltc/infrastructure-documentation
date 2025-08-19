# LTC Infrastructure Documentation

Information about the architecture and makeup of the LTC's server infrastructure.

## Developing using Codespaces

1. Create an issue & branch for your work
1. [Open repo in Codespaces](https://codespaces.new/bcit-ltc/infrastructure-documentation) and checkout your branch
1. Open a terminal and run

    docker compose up

1. Browse to `http://localhost:8080` (for browser-based sessions: command palette: `>open port in browser`).

## Developing using your own environment

### Dependencies

For basic development:

- `docker` or `buildah`

And to test cluster deployment:

- `kubectl`
- `helm`
- `direnv`
- `k3d`
- `skaffold`

## Testing cluster deployment

1. Run `make cluster` (and optionally, `make dashboard` for the [Kubernetes-dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) app), followed by `skaffold dev`

## Cleanup

To remove all cluster resources, run `make delete`.

## License

Mozilla Public License 2.0

Developed in 🇨🇦 Canada at the [British Columbia Institute of Technology](https://www.bcit.ca/) [Learning and Teaching Centre](https://www.bcit.ca/learning-teaching-centre/).
