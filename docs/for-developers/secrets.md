# Secrets

If your application uses any kind of secret, you should be storing and retrieving these from [Vault](https://vault.ltc.bcit.ca).

Deployments to `review` branches can be configured to use local secrets, either added as a resource in the overlay or created using a `kustomize secretGenerator`. Secrets to `latest` or `stable` environments use [Vault Secret Operator](https://developer.hashicorp.com/vault/tutorials/kubernetes/vault-secrets-operator) custom resource definitions.

Use the following examples to craft resources for `latest` and `stable` overlays:

=== "latest"

        something

=== "stable"

        another thing
