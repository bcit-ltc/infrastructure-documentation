<!-- SPDX-License-Identifier: MPL-2.0 -->
# LTC Infrastructure Documentation

Information about the architecture and makeup of the LTC's infrastructure.

## Getting Started

For basic local development using `docker compose`:

- install [docker](https://docs.docker.com/desktop/) or [orbstack](https://docs.orbstack.dev/install)
- run `docker compose up` and browse to `http://localhost:8080`

## Develop using Codespaces

1. [Open your branch in Codespaces](https://codespaces.new/bcit-ltc/infrastructure-documentation).
1. Open a terminal and run:

    direnv allow
    docker compose up

1. Browse to `http://localhost:8080` (for browser-based sessions: command palette: `>open port in browser`).

### Testing Deployment

Run `make help` within a Codespace to see options.

- If you're using your own environment, here's one way to do it:

    ```bash
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate
    nix-shell -p direnv kubectl kubernetes-helm k3d skaffold
    ```

Run `make check` to confirm the environment is ready.

Run `make cluster` (and optionally, `make dashboard` for the [Kubernetes-dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) app)

Test deployment with `skaffold dev`.

### Cleanup

To remove all cluster resources, run `make delete`.

## License

This Source Code Form is subject to the terms of the Mozilla Public License, v2.0. If a copy of the MPL was not distributed with this file, You can obtain one at <https://mozilla.org/MPL/2.0/>.

## About

Developed in 🇨🇦 Canada by the [Learning and Teaching Centre](https://www.bcit.ca/learning-teaching-centre/) at [BCIT](https://www.bcit.ca/).

