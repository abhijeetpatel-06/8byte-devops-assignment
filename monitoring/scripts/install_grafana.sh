#!/usr/bin/env bash
# install_grafana.sh
# ------------------------------------------------------------------
# Grafana baaki tools se thoda alag hai - isko hum tar.gz se nahi,
# official apt repo se install karenge. Fayda ye hai ki updates
# `apt upgrade` se hi mil jayenge aur ye apna systemd service khud
# bana leta hai (grafana-server.service), humein alag se likhna nahi
# padta - isliye systemd/ folder me grafana.service file nahi hai.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
source "$SCRIPT_DIR/../config.env"

check_root

log "Grafana ke liye apt repo add kar rahe hain..."

apt-get install -y -qq apt-transport-https software-properties-common wget gnupg2

mkdir -p /etc/apt/keyrings
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor -o /etc/apt/keyrings/grafana.gpg
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" \
    > /etc/apt/sources.list.d/grafana.list

apt-get update -qq
apt-get install -y grafana

# default port 3000 hai, agar config.env me alag port diya hai to change karo
if [[ "$GRAFANA_PORT" != "3000" ]]; then
    sed -i "s/^;http_port = 3000/http_port = ${GRAFANA_PORT}/" /etc/grafana/grafana.ini
    log "Grafana port ${GRAFANA_PORT} pe set kar diya"
fi

# admin credentials config.env se set - UI me default admin/admin dikhna
# nahi chahiye production me
sed -i "s/^;admin_user = admin/admin_user = ${GRAFANA_ADMIN_USER}/" /etc/grafana/grafana.ini
sed -i "s/^;admin_password = admin/admin_password = ${GRAFANA_ADMIN_PASSWORD}/" /etc/grafana/grafana.ini

# provisioning aur dashboards apply_config.sh copy karega, yaha bas
# folders bana rahe hain taki wo file safely daal sake
mkdir -p /etc/grafana/provisioning/datasources
mkdir -p /etc/grafana/provisioning/dashboards
mkdir -p /var/lib/grafana/dashboards
chown -R grafana:grafana /var/lib/grafana/dashboards

systemctl daemon-reload
systemctl enable grafana-server

log "Grafana install ho gaya. Config apply karke start karna: systemctl start grafana-server"
warn "Login: ${GRAFANA_ADMIN_USER} / (config.env me jo password rakha hai wo)"
