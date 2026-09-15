# Monitoring Stack (Prometheus + Grafana + Loki + Alertmanager)

Ye ek ready-to-run monitoring setup hai jo server ke metrics (CPU, RAM,
Disk, Network) aur logs, dono ko ek jagah Grafana pe dikha deta hai,
aur kuch gadbad ho to Slack/Email pe alert bhi bhej deta hai.

Test/build Ubuntu 22.04/24.04 ko dhyan me rakh ke kiya gaya hai. Doosre
distro pe chalega but apt commands wagera adjust karne padenge.

## Isme kya kya hai

| Component     | Kaam kya karta hai                                  |
|----------------|------------------------------------------------------|
| Prometheus     | Metrics collect + store karta hai                    |
| Node Exporter  | Server ke CPU/RAM/Disk/Network metrics expose karta hai |
| Alertmanager   | Prometheus se alerts leke Slack/Email pe route karta hai |
| Loki           | Logs store karta hai                                  |
| Promtail       | Log files padh ke Loki ko bhejta hai                  |
| Grafana        | Sab kuch visualize karne ke liye dashboards           |

## Pehle ye karo

Sab kuch `config.env` file se control hota hai - server IP, ports,
passwords, Slack webhook, SMTP details, sab yahi ek jagah hai.

```bash
nano config.env
```

Kam se kam ye cheeze zaroor badlo (defaults sirf example ke liye hain):

- `SERVER_IP` - apna actual server IP (ya localhost ke liye `127.0.0.1`)
- `GRAFANA_ADMIN_PASSWORD` - default password kabhi production me mat rakhna
- `SLACK_WEBHOOK_URL` - agar Slack alerts chahiye
- `SMTP_*` aur `ALERT_EMAIL_TO` - agar Email alerts chahiye
- `APP_LOG_PATH` - apni application ki actual log file ka path

Agar Slack ya Email me se ek hi use karna hai to `alertmanager.yml` me
jo use nahi karna uska block hata sakte ho, warna wo bhi try karega
aur agar webhook/smtp galat hai to bas ek warning log me aayegi, kuch
crash nahi hoga.

## Install karna

Sabse aasan tarika - ek hi script sab kuch kar dega:

```bash
sudo ./setup.sh
```

Ye order me karega: Prometheus -> Node Exporter -> Alertmanager ->
Loki -> Promtail -> Grafana, phir sab configs apply karega aur
services start kar dega.

Agar sirf ek component chahiye (jaise sirf naya server add kar rahe ho
jisme sirf Node Exporter chalana hai), individual script chala sakte ho:

```bash
sudo ./scripts/install_node_exporter.sh
```

## Kuch change karna ho baad me

Maan lo Slack webhook change ho gaya, ya server IP badal gaya - poora
reinstall karne ki zarurat nahi:

```bash
nano config.env          # jo bhi change karna hai wo karo
sudo ./scripts/apply_config.sh
sudo systemctl restart prometheus alertmanager loki promtail grafana-server
```

`apply_config.sh` sirf configs ko dobara render karke sahi jagah copy
karta hai (`/etc/prometheus`, `/etc/loki`, waghera) - binaries ko haath
nahi lagata.

## Access karna

Setup hone ke baad (config.env me diye SERVER_IP/PORTS ke hisaab se):

- Grafana: `http://<SERVER_IP>:3000` (login jo `config.env` me set kiya)
- Prometheus: `http://<SERVER_IP>:9090`
- Alertmanager: `http://<SERVER_IP>:9093`

Grafana khulte hi 3 dashboards already provisioned milenge:
Infrastructure, Application, aur Database (Server Monitoring folder ke andar).

> Database dashboard tabhi data dikhayega jab mysqld_exporter ya
> postgres_exporter chala rakha ho aur `prometheus/prometheus.yml` me
> `database` job ka comment hata ke target daala ho.

## Folder structure

```
monitoring/
├── config.env                  <- sirf ye file edit karni hai zyada tar
├── setup.sh                    <- ek command me sab install
├── prometheus/
│   ├── prometheus.yml
│   └── alert_rules.yml
├── grafana/
│   ├── dashboards/              (3 pre-built dashboards)
│   └── provisioning/            (datasource + dashboard auto-config)
├── loki/
│   └── loki-config.yml
├── promtail/
│   └── promtail-config.yml
├── alertmanager.yml
├── scripts/
│   ├── common.sh                <- shared helper functions
│   ├── apply_config.sh          <- configs render + apply
│   └── install_*.sh             <- har component ka apna installer
└── systemd/
    └── *.service                <- unit files (templates, placeholders ke saath)
```

## Troubleshooting - jo common issues aate hain

- **Service start nahi ho raha**: `journalctl -u <service_name> -n 50 --no-pager`
  se logs dekho, 90% cases me config file me koi typo ya permission issue hota hai.
- **Grafana me datasource "unreachable" dikha raha hai**: `SERVER_IP` config.env
  me sahi hai check karo, aur firewall me relevant ports (9090, 3100) khule
  hain ya nahi dekho.
- **Alerts nahi aa rahe**: pehle Alertmanager UI (`:9093`) pe check karo alert
  aaya bhi hai ya nahi. Agar wahi nahi hai to Prometheus rules check karo, agar
  wahan hai but Slack/Email nahi aaya to webhook/SMTP credentials galat hain.
- **Disk full ho gaya**: `PROMETHEUS_RETENTION` aur Loki ke `retention_period`
  kam kar do config me, purana data zyada din tak mat rakho.

Bas itna hi hai. Kuch aur zarurat pade to scripts ke andar comments
padh lena, mostly self-explanatory rakhne ki koshish ki hai.
