## Build
#
FROM squidfunk/mkdocs-material AS build

WORKDIR /app

RUN set -ex \
    && pip install \
        Pygments \
        pymdown-extensions \
        mkdocs-git-revision-date-localized-plugin \
    ;

COPY . /app

RUN set -ex \
    && mkdocs build --site-dir /public


## Release
#
FROM nginxinc/nginx-unprivileged:alpine3.22-perl

LABEL maintainer=courseproduction@bcit.ca

# Upgrade all packages to minimize vulnerabilities
# RUN apk update && apk upgrade

COPY --from=build /public /usr/share/nginx/html/
