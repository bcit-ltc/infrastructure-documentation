# Dockerfile

## Build stage
FROM squidfunk/mkdocs-material AS build

WORKDIR /app

ARG STATIC_ROOT=/public

RUN set -ex \
    && pip install --no-cache-dir \
        Pygments \
        pymdown-extensions \
        mkdocs-git-revision-date-localized-plugin

COPY . /app

RUN set -ex \
    && mkdocs build --site-dir "${STATIC_ROOT}"

## Release
FROM nginxinc/nginx-unprivileged:alpine3.22-perl

LABEL maintainer="courseproduction@bcit.ca"
LABEL org.opencontainers.image.source="https://github.com/bcit-ltc/infrastructure-documentation"
LABEL org.opencontainers.image.description="Information about the architecture and makeup of the LTC's server infrastructure."

ARG STATIC_ROOT=/public

COPY conf.d/default.conf /etc/nginx/conf.d/default.conf

COPY --from=build "${STATIC_ROOT}/" /usr/share/nginx/html
