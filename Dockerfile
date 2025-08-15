## Build
FROM squidfunk/mkdocs-material AS build
WORKDIR /app

# exact same packages; just avoid cache
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

COPY --from=build /public /usr/share/nginx/html/
