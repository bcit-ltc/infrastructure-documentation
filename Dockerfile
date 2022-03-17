FROM squidfunk/mkdocs-material as docs-base

WORKDIR /docs

RUN set -ex; \
    pip install Pygments pymdown-extensions;

COPY . .

RUN set -ex; \
    mkdocs build --site-dir /public;


######################
FROM nginx

LABEL maintainer courseproduction@bcit.ca

COPY --from=docs-base /public /usr/share/nginx/html