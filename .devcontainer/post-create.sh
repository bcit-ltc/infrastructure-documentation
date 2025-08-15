#!/bin/bash

# this runs at Codespace creation - not part of pre-build

echo "=== post-create start ===" | tee -a "$HOME/status"

# # Enable shell completion for k3d
# source <(k3d completion bash)
# k3d completion bash > /etc/bash_completion.d/k3d

echo "alias l='ls -hAlF'" >> ~/.bashrc

# Create `dashboard.sh` to print dashboard admin user token and proxy dashboard
cat << 'EOF' > /usr/local/bin/dashboard
#!/bin/bash

# Retrieve token
DASHBOARD_TOKEN=$(kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d)

# Display token and port-forward dashboard
echo -e "\n\nDashboard Token: $DASHBOARD_TOKEN\n\n"

kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
EOF

chmod +x /usr/local/bin/dashboard

echo "alias dashboard='/usr/local/bin/dashboard'" >> ~/.bashrc

# update the repos
# git -C /workspaces/imdb-app pull
# git -C /workspaces/webvalidate pull

echo "=== post-create complete ===" | tee -a "$HOME/status"
