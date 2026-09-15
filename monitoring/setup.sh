#!/usr/bin/env bash
# setup.sh
# ------------------------------------------------------------------
# Master script - agar aalas aa raha hai har script alag se chalane
# ka to bas ye ek chala do, sab kuch order me ho jayega:
#   1. config.env se saari values load
#   2. har component install (prometheus, node_exporter, alertmanager,
#      loki, promtail, grafana)
#   3. sab configs apply
#   4. saari services start
#
# Usage:
#   1. config.env kholo, apna SERVER_IP, passwords, webhook url etc bhar do
#   2. sudo ./setup.sh
#
# Agar kisi ek component me hi dobara install/update karna ho to
# uska scripts/install_*.sh alag se bhi chala sakte ho, ye zaruri nahi
# ki har baar poora setup.sh hi chalao.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/common.sh"

check_root

if [[ ! -f "$SCRIPT_DIR/config.env" ]]; then
    err "config.env nahi mili! Isse pehle wo file bhar lo (SERVER_IP, passwords, etc.)"
    exit 1
fi

log "=== Monitoring stack setup shuru ==="
echo

log "Package list update kar rahe hain (grafana apt install ke liye zaroori)..."
apt-get update -qq

log "--- Step 1/6: Prometheus ---"
bash "$SCRIPT_DIR/scripts/install_prometheus.sh"
echo

log "--- Step 2/6: Node Exporter ---"
bash "$SCRIPT_DIR/scripts/install_node_exporter.sh"
echo

log "--- Step 3/6: Alertmanager ---"
bash "$SCRIPT_DIR/scripts/install_alertmanager.sh"
echo

log "--- Step 4/6: Loki ---"
bash "$SCRIPT_DIR/scripts/install_loki.sh"
echo

log "--- Step 5/6: Promtail ---"
bash "$SCRIPT_DIR/scripts/install_promtail.sh"
echo

log "--- Step 6/6: Grafana ---"
bash "$SCRIPT_DIR/scripts/install_grafana.sh"
echo

log "--- Configs apply kar rahe hain ---"
bash "$SCRIPT_DIR/scripts/apply_config.sh"
echo

log "--- Services start kar rahe hain ---"
systemctl restart prometheus
systemctl restart node_exporter
systemctl restart alertmanager
systemctl restart loki
systemctl restart promtail
systemctl restart grafana-server

echo
log "=== Setup complete! ==="
source "$SCRIPT_DIR/config.env"
echo "  Prometheus   -> http://${SERVER_IP}:${PROMETHEUS_PORT}"
echo "  Alertmanager -> http://${SERVER_IP}:${ALERTMANAGER_PORT}"
echo "  Grafana      -> http://${SERVER_IP}:${GRAFANA_PORT}  (login: ${GRAFANA_ADMIN_USER})"
echo "  Loki         -> http://${SERVER_IP}:${LOKI_PORT}  (directly UI nahi hai, Grafana se query karo)"
echo
warn "Sab kuch theek se check karne ke liye: systemctl status prometheus grafana-server loki promtail alertmanager"
