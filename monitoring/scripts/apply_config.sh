#!/usr/bin/env bash
# apply_config.sh
# ------------------------------------------------------------------
# Ye script har config file (prometheus.yml, loki-config.yml, waghera)
# ko config.env ki values ke saath render karke uski asli jagah
# (/etc/...) pe copy kar deta hai.
#
# Jab bhi config.env me kuch change karo (naya IP, naya webhook url,
# port waghera), bas ye script dobara chala do aur phir concerned
# service ko restart kar do. Poora reinstall karne ki zarurat nahi.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$SCRIPT_DIR/common.sh"
source "$PROJECT_ROOT/config.env"

check_root

log "Config files render karke apply kar rahe hain..."

# ---- Prometheus ----
render_template "$PROJECT_ROOT/prometheus/prometheus.yml"   "$PROMETHEUS_CONFIG_DIR/prometheus.yml"
render_template "$PROJECT_ROOT/prometheus/alert_rules.yml"  "$PROMETHEUS_CONFIG_DIR/alert_rules.yml"
chown -R prometheus:prometheus "$PROMETHEUS_CONFIG_DIR" 2>/dev/null || warn "prometheus user nahi mila, chown skip"

# ---- Alertmanager ----
render_template "$PROJECT_ROOT/alertmanager.yml" "$ALERTMANAGER_CONFIG_DIR/alertmanager.yml"
chown -R alertmanager:alertmanager "$ALERTMANAGER_CONFIG_DIR" 2>/dev/null || warn "alertmanager user nahi mila, chown skip"

# ---- Loki ----
render_template "$PROJECT_ROOT/loki/loki-config.yml" "$LOKI_CONFIG_DIR/loki-config.yml"
chown -R loki:loki "$LOKI_CONFIG_DIR" 2>/dev/null || warn "loki user nahi mila, chown skip"

# ---- Promtail ----
render_template "$PROJECT_ROOT/promtail/promtail-config.yml" "$PROMTAIL_CONFIG_DIR/promtail-config.yml"

# ---- Grafana provisioning + dashboards ----
render_template "$PROJECT_ROOT/grafana/provisioning/datasource.yml" "/etc/grafana/provisioning/datasources/datasource.yml"
cp "$PROJECT_ROOT/grafana/provisioning/dashboards.yml" "/etc/grafana/provisioning/dashboards/dashboards.yml"
cp "$PROJECT_ROOT/grafana/dashboards/"*.json "/var/lib/grafana/dashboards/"
chown -R grafana:grafana /etc/grafana/provisioning /var/lib/grafana/dashboards 2>/dev/null || warn "grafana user nahi mila, chown skip"

log "Saari configs apply ho gayi."
warn "Ab services ko restart karna mat bhoolna: systemctl restart prometheus alertmanager loki promtail grafana-server"
