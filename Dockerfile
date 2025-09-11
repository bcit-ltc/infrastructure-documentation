# Dockerfile
## Build
FROM squidfunk/mkdocs-material AS build
WORKDIR /app

RUN set -ex \
    && pip install --no-cache-dir \
        Pygments \
        pymdown-extensions \
        mkdocs-git-revision-date-localized-plugin

COPY . /app

RUN set -ex \
    && mkdocs build --site-dir /public

## Release
FROM nginxinc/nginx-unprivileged:alpine3.22-perl

LABEL maintainer=courseproduction@bcit.ca

LABEL org.opencontainers.image.description="Information about the architecture and makeup of the LTC's server infrastructure."

COPY --from=build /public /usr/share/nginx/html/
