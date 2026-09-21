#!/usr/bin/env bash
set -e

echo ">>> Actualizando sistema..."
apt-get update
apt-get upgrade -y

echo ">>> Instalando Docker..."
curl -fsSL https://get.docker.com | sh

echo ">>> Instalando Docker Compose..."
apt-get install -y docker-compose

echo ">>> Añadiendo usuario vagrant al grupo docker..."
usermod -aG docker vagrant

echo ">>> Provisioning completado."