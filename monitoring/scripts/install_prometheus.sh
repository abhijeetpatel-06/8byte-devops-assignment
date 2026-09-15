#!/usr/bin/env bash
# install_prometheus.sh
# ------------------------------------------------------------------
# Prometheus binary download karke systemd service ke through chalata hai.
# Idempotent rakhne ki koshish ki hai - dobara chalao to crash nahi karega,
# bas overwrite kar dega jo already hai.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
source "$SCRIPT_DIR/../config.env"

check_root

log "Prometheus v${PROMETHEUS_VERSION} install kar rahe hain..."

# dedicated user - root se services chalana acchi practice nahi hai
if ! id -u prometheus &>/dev/null; then
    useradd --no-create-home --shell /usr/sbin/nologin prometheus
    log "prometheus system user bana diya"
else
    warn "prometheus user pehle se hai, skip kar rahe hain"
fi

mkdir -p "$PROMETHEUS_DATA_DIR" "$PROMETHEUS_CONFIG_DIR"

cd /tmp
DL_URL="https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz"
log "Downloading from $DL_URL"
curl -sSL -o prometheus.tar.gz "$DL_URL"
tar -xzf prometheus.tar.gz
cd "prometheus-${PROMETHEUS_VERSION}.linux-amd64"

cp prometheus /usr/local/bin/
cp promtool /usr/local/bin/
# console files bhi copy karlo, web UI ke kuch templates inpe depend karte hain
mkdir -p "$PROMETHEUS_CONFIG_DIR/consoles" "$PROMETHEUS_CONFIG_DIR/console_libraries"
cp -r consoles/* "$PROMETHEUS_CONFIG_DIR/consoles/" 2>/dev/null || true
cp -r console_libraries/* "$PROMETHEUS_CONFIG_DIR/console_libraries/" 2>/dev/null || true

chown -R prometheus:prometheus "$PROMETHEUS_DATA_DIR" "$PROMETHEUS_CONFIG_DIR"

# cleanup - /tmp me kachra nahi chodna
cd /tmp && rm -rf prometheus.tar.gz "prometheus-${PROMETHEUS_VERSION}.linux-amd64"

# actual config file copy karne ka kaam apply_config.sh karta hai
# (kyuki usme placeholders replace karne padte hain), yaha sirf
# binary + service setup ho raha hai
render_template "$SCRIPT_DIR/../systemd/prometheus.service" "/etc/systemd/system/prometheus.service"

systemctl daemon-reload
systemctl enable prometheus
log "Prometheus install ho gaya. Config apply karne ke baad start karna: systemctl start prometheus"
