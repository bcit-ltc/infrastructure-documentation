<!-- SPDX-License-Identifier: MPL-2.0 -->

# LTC Infrastructure Documentation

Information about the architecture and makeup of the LTC's server infrastructure.

## Develop using Codespaces

1. [Open your branch in Codespaces](https://codespaces.new/bcit-ltc/infrastructure-documentation).
1. Open a terminal and run:

    direnv allow
    docker compose up

1. Browse to `http://localhost:8080` (for browser-based sessions: command palette: `>open port in browser`).

## Develop using your own environment

For basic local development using `docker compose`:

- install [docker](https://docs.docker.com/desktop/) or [orbstack](https://docs.orbstack.dev/install)
- set `APP_NAME` environment variable: `export APP_NAME=myAwesomeApp`
- run `docker compose up` and browse to `http://localhost:8080`

## Testing Deployment

The easiest way to load a working environment is to install Nix, and then hook `direnv` into your shell. The Codespaces environment is ready to go; if you're using your own environment, here's one way to do it:

    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --determinate
    nix-shell -p direnv kubectl kubernetes-helm k3d skaffold

Run `make cluster` (and optionally, `make dashboard` for the [Kubernetes-dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) app), followed by `skaffold dev`.

`make help` shows other helpful commands for this environment.

### Cleanup

To remove all cluster resources, run `make delete`.

## License

This Source Code Form is subject to the terms of the Mozilla Public License, v2.0. If a copy of the MPL was not distributed with this file, You can obtain one at <https://mozilla.org/MPL/2.0/>.

## About

Developed in 🇨🇦 Canada by the [Learning and Teaching Centre](https://www.bcit.ca/learning-teaching-centre/) at [BCIT](https://www.bcit.ca/).
