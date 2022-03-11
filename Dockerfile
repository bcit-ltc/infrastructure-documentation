FROM squidfunk/mkdocs-material as docs-base

RUN pip install Pygments pymdown-extensions

WORKDIR /docs

COPY . .

RUN mkdocs build --site-dir /public



######################
FROM nginx
LABEL maintainer courseproduction@bcit.ca

COPY --from=docs-base /public /usr/share/nginx/html