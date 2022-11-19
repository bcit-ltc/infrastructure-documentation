# Strategy

Whether it's a small interaction for an single course, or a larger, more complicated application for an entire program, we develop and build *containerized apps* that can be deployed on Kubernetes.

!!! tip "Development Strategy"

    Rather than building every functional component into one large monolith, the approach is to build smaller apps that have one purpose, and then connect them together with API calls. This makes it easier to update a specific component without having to change to something that already works well.

    For example, an authentication component that interfaces with a front-end does not need to be part of the same code base as a data conversion engine that is part of the back-end.
