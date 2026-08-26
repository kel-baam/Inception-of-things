#!/usr/bin/env bash
set -eux

SERVER_IP="$1"

apt-get update -qq
apt-get install -y curl

# Find the interface that actually has SERVER_IP, instead of guessing eth1/enp0sX.
IFACE=$(ip -o addr show | awk -v ip="$SERVER_IP" '$0 ~ ip {print $2}')

# NOTE: unlike Part 1, we KEEP Traefik enabled here — it's the ingress
# controller we use to route by Host header to the 3 apps.
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --node-ip=${SERVER_IP} \
  --advertise-address=${SERVER_IP} \
  --flannel-iface=${IFACE} \
  --write-kubeconfig-mode=644 \
  --disable=metrics-server" sh -s -

# Wait for the API server to actually be ready before applying manifests.
until k3s kubectl get nodes >/dev/null 2>&1; do
  sleep 2
done

# Apply the 3 apps + ingress
k3s kubectl apply -f /vagrant/confs/

echo "== k3s + 3 apps ready on ${SERVER_IP} =="