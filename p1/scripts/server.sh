#!/usr/bin/env bash
set -eux

apt-get update -qq
apt-get install -y curl

IFACE=$(ip -o addr show | awk '/192\.168\.56\.110/ {print $2}')

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server \
  --node-ip=192.168.56.110 \
  --advertise-address=192.168.56.110 \
  --flannel-iface=${IFACE} \
  --write-kubeconfig-mode=644 \
  --disable=traefik \
  --disable=servicelb \
  --disable=metrics-server" sh -s -

until [ -f /var/lib/rancher/k3s/server/node-token ]; do
  sleep 2
done

cp /var/lib/rancher/k3s/server/node-token /vagrant/token