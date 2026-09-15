#!/usr/bin/env bash
# install_node_exporter.sh
# ------------------------------------------------------------------
# Ye simplest wala hai in sab me - node_exporter ko config file ki
# zarurat hi nahi hoti, seedha binary chala do bas.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
source "$SCRIPT_DIR/../config.env"

check_root

log "Node Exporter v${NODE_EXPORTER_VERSION} install kar rahe hain..."

if ! id -u node_exporter &>/dev/null; then
    useradd --no-create-home --shell /usr/sbin/nologin node_exporter
fi

cd /tmp
DL_URL="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz"
log "Downloading from $DL_URL"
curl -sSL -o node_exporter.tar.gz "$DL_URL"
tar -xzf node_exporter.tar.gz

cp "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter" /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter

rm -rf node_exporter.tar.gz "node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64"

render_template "$SCRIPT_DIR/../systemd/node_exporter.service" "/etc/systemd/system/node_exporter.service"

systemctl daemon-reload
systemctl enable node_exporter
systemctl restart node_exporter

log "Node Exporter chalu ho gaya port ${NODE_EXPORTER_PORT} pe (check: curl localhost:${NODE_EXPORTER_PORT}/metrics)"
