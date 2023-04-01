# Secrets

If your application uses any kind of secret, you should be storing and retrieving these from [Vault](https://vault.ltc.bcit.ca).

Use the following annotations in your `latest` and `stable` overlays to configure automatic secret retrieval:

=== "latest"

        kind: Deployment
        spec:
            template:
                metadata:
                annotations:
                    vault.hashicorp.com/agent-inject: "true"
                    vault.hashicorp.com/role: "ptracker-kubeauthbot-latest"
                    vault.hashicorp.com/agent-inject-secret-config: "web-apps/data/ptracker"
                    vault.hashicorp.com/agent-inject-template-config: |
                    {{ with secret "web-apps/data/ptracker" -}}
                    MARIADB_PASSWORD={{ .Data.data.MARIADB_PASSWORD }}
                    MARIADB_USER={{ .Data.data.MARIADB_USER }}
                    {{- end }}

=== "stable"

        kind: Deployment
        spec:
            template:
                metadata:
                annotations:
                    vault.hashicorp.com/agent-inject: "true"
                    vault.hashicorp.com/role: "ptracker-kubeauthbot-stable"
                    vault.hashicorp.com/agent-inject-secret-config: "web-apps/data/ptracker"
                    vault.hashicorp.com/agent-inject-template-config: |
                    {{ with secret "web-apps/data/ptracker" -}}
                    MARIADB_PASSWORD={{ .Data.data.MARIADB_PASSWORD }}
                    MARIADB_USER={{ .Data.data.MARIADB_USER }}
                    {{- end }}
