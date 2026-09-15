#!/usr/bin/env bash
# install_loki.sh
# ------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
source "$SCRIPT_DIR/../config.env"

check_root

log "Loki v${LOKI_VERSION} install kar rahe hain..."

if ! id -u loki &>/dev/null; then
    useradd --no-create-home --shell /usr/sbin/nologin loki
fi

mkdir -p "$LOKI_CONFIG_DIR" "$LOKI_DATA_DIR"

cd /tmp
DL_URL="https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-amd64.zip"
log "Downloading from $DL_URL"
curl -sSL -o loki.zip "$DL_URL"
unzip -o loki.zip
chmod +x loki-linux-amd64
mv loki-linux-amd64 /usr/local/bin/loki

chown -R loki:loki "$LOKI_CONFIG_DIR" "$LOKI_DATA_DIR"

rm -f /tmp/loki.zip

render_template "$SCRIPT_DIR/../systemd/loki.service" "/etc/systemd/system/loki.service"

systemctl daemon-reload
systemctl enable loki

log "Loki install ho gaya. Config apply karke start karna: systemctl start loki"
