#!/usr/bin/env bash
# install_promtail.sh
# ------------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
source "$SCRIPT_DIR/../config.env"

check_root

log "Promtail v${PROMTAIL_VERSION} install kar rahe hain..."

mkdir -p "$PROMTAIL_CONFIG_DIR" /var/lib/promtail

cd /tmp
DL_URL="https://github.com/grafana/loki/releases/download/v${PROMTAIL_VERSION}/promtail-linux-amd64.zip"
log "Downloading from $DL_URL"
curl -sSL -o promtail.zip "$DL_URL"
unzip -o promtail.zip
chmod +x promtail-linux-amd64
mv promtail-linux-amd64 /usr/local/bin/promtail

rm -f /tmp/promtail.zip

render_template "$SCRIPT_DIR/../systemd/promtail.service" "/etc/systemd/system/promtail.service"

systemctl daemon-reload
systemctl enable promtail

log "Promtail install ho gaya. Config apply karke start karna: systemctl start promtail"
