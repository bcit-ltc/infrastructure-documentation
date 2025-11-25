# Dockerfile

## Build
FROM squidfunk/mkdocs-material AS build
WORKDIR /app

RUN set -ex \
    && pip install --no-cache-dir \
        Pygments \
        pymdown-extensions \
        mkdocs-git-revision-date-localized-plugin

# Copy all sources, including conf.d/cdn/CDN_ASSET_VERSION and scripts/
COPY . /app

# Ensure the rewrite script is executable
RUN chmod +x /app/scripts/cdn_rewrite.sh

# Build static site, then rewrite asset URLs to point at the CDN version
RUN set -ex \
    && mkdocs build --site-dir /public \
    && /app/scripts/cdn_rewrite.sh /public

## Release
FROM nginxinc/nginx-unprivileged:alpine3.22-perl

LABEL maintainer=courseproduction@bcit.ca
LABEL org.opencontainers.image.source="https://github.com/bcit-ltc/infrastructure-documentation"
LABEL org.opencontainers.image.description="Information about the architecture and makeup of the LTC's server infrastructure."

COPY conf.d/default.conf /etc/nginx/conf.d/default.conf
COPY --from=build /public /usr/share/nginx/html/
