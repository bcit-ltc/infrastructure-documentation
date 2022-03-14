FROM squidfunk/mkdocs-material as docs-base

WORKDIR /docs

COPY . .

RUN set -ex; \
    pip install Pygments pymdown-extensions; \
    mkdocs build --site-dir /public;


######################
FROM nginx

LABEL maintainer courseproduction@bcit.ca

COPY --from=docs-base /public /usr/share/nginx/html