FROM ghcr.io/k3d-io/k3d:5-dind

# ARG USERNAME=vscode

RUN apk add --no-cache helm kustomize

RUN curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
  install skaffold /usr/local/bin/ && \
  rm skaffold
