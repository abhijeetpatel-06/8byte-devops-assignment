#!/usr/bin/env bash
# install_alertmanager.sh
# ------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
source "$SCRIPT_DIR/../config.env"

check_root

log "Alertmanager v${ALERTMANAGER_VERSION} install kar rahe hain..."

if ! id -u alertmanager &>/dev/null; then
    useradd --no-create-home --shell /usr/sbin/nologin alertmanager
fi

mkdir -p "$ALERTMANAGER_CONFIG_DIR" "$ALERTMANAGER_DATA_DIR"

cd /tmp
DL_URL="https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz"
log "Downloading from $DL_URL"
curl -sSL -o alertmanager.tar.gz "$DL_URL"
tar -xzf alertmanager.tar.gz
cd "alertmanager-${ALERTMANAGER_VERSION}.linux-amd64"

cp alertmanager /usr/local/bin/
cp amtool /usr/local/bin/

chown -R alertmanager:alertmanager "$ALERTMANAGER_CONFIG_DIR" "$ALERTMANAGER_DATA_DIR"

cd /tmp && rm -rf alertmanager.tar.gz "alertmanager-${ALERTMANAGER_VERSION}.linux-amd64"

render_template "$SCRIPT_DIR/../systemd/alertmanager.service" "/etc/systemd/system/alertmanager.service"

systemctl daemon-reload
systemctl enable alertmanager

log "Alertmanager install ho gaya. Config apply karke start karna: systemctl start alertmanager"
