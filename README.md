# LTC Infrastructure Documentation

Information about the architecture and makeup of the LTC's server infrastructure.

## Developing

1. Create an issue
1. Checkout the branch in your code editor
1. Open a terminal and run

    docker compose up

1. Browse to `http://localhost:8000`.

## Confirm Deployment

1. Run `make cluster` (and optionally, `make dashboard`), followed by `skaffold dev`

## Cleanup

To remove all cluster resources, run `make delete`.

## License

Mozilla Public License 2.0

Developed in Canada at the [British Columbia Institute of Technology](https://www.bcit.ca/) [Learning and Teaching Centre](https://www.bcit.ca/learning-teaching-centre/).
