# LTC Infrastructure Documentation

Information about the architecture and makeup of the LTC's server infrastructure.

## Developing

1. Create an issue and a merge request
1. Checkout the branch in your code editor
1. Open a terminal and run

    docker run --rm -it -p 8000:8000 -v ${PWD}:/docs squidfunk/mkdocs-material

1. Browse to `http://localhost:8000` to see site with *live reload* enabled.

## Building

1. Create an issue and a merge request
1. Checkout the branch in your code editor
1. Commit and push to the repo. The CI/CD pipeline will build and push the image to the cluster specified in the `.gitlab-ci.yml` file.

