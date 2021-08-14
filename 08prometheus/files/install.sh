#!/bin/bash

##################################################
dnf install -y epel-release chrony ntpstat && dnf update

##################################################
### NTP
mv /etc/localtime  /etc/localtime.old
ln -s  /usr/share/zoneinfo/Europe/Minsk   /etc/localtime
sed -i '/pool 2.centos/c pool ntp3.stratum2.ru iburst' /etc/chrony.conf
systemctl enable --now chronyd
chronyc sources
ntpstat

##################################################
### Prometheus
groupadd --system prometheus
useradd -s /sbin/nologin --system -g prometheus prometheus

mkdir /var/lib/prometheus

for i in rules rules.d files_sd; do
 mkdir -p /etc/prometheus/${i};
done

cd /tmp
curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest \
    | grep browser_download_url \
    | grep linux-amd64 \
    | cut -d '"' -f 4 \
    | wget -qi -
tar xvf prometheus-*.tar.gz
cd prometheus-*/
cp prometheus promtool /usr/local/bin/
cp -r consoles/ console_libraries/ /etc/prometheus/

cat <<EOF > /etc/prometheus/prometheus.yml
# Global config
global: 
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.  
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.  
  scrape_timeout:      15s # scrape_timeout is set to the global default (10s).

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'
    static_configs:
      - targets: ['192.168.1.10:9090']
  
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['192.168.1.20:9100']

  # Using the [icmp] module
  - job_name: 'Blackbox_ICMP'
    metrics_path: /probe
    params:
      module: [icmp]
    static_configs:
      - targets:
        # The hostname or IP address of the host you are targeting
        - 192.168.1.20
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        # Where Blackbox exporter was installed plust port
        replacement: 192.168.1.10:9115

  # Using the [ssh_banner] module
  - job_name: 'Blackbox_tomcat'
    metrics_path: /probe
    params:
      module: [ssh_banner]
    static_configs:
      - targets:
        # The host you are targeting plus ssh port
        - 192.168.1.20:8080
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        # Where Blackbox exporter was installed plust port
        replacement: 192.168.1.10:9115

  # Using the [http_2xx] module
  - job_name: 'Blackbox_http'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        # The http host you are targeting
        - http://192.168.1.20:8080/sample
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        #Where Blackbox exporter was installed plust port
        replacement: 192.168.1.10:9115
EOF

# !!! "GOMAXPROCS=2"  2 - number of vcpu
cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
Environment="GOMAXPROCS=2"
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.external-url=

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF

for i in rules rules.d files_sd; do
  chown -R prometheus:prometheus /etc/prometheus/${i};
done
for i in rules rules.d files_sd; do
  chmod -R 775 /etc/prometheus/${i};
done
chown -R prometheus:prometheus /var/lib/prometheus/

systemctl daemon-reload
systemctl start prometheus

firewall-cmd --add-port=9090/tcp --permanent
# firewall-cmd --permanent --add-rich-rule 'rule family="ipv4" \
# source address="192.168.1.0/24" port protocol="tcp" port="9090" accept'
firewall-cmd --reload

##################################################
### Grafana
cat <<EOF > /etc/yum.repos.d/grafana.repo
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF

dnf update -y && dnf install -y grafana

systemctl enable grafana-server
systemctl start grafana-server

firewall-cmd --add-port=3000/tcp --permanent
firewall-cmd --reload

##################################################
### Blackbox_exporter
cd /tmp
curl -s https://api.github.com/repos/prometheus/blackbox_exporter/releases/latest \
    | grep browser_download_url \
    | grep linux-amd64 \
    | cut -d '"' -f 4 \
    | wget -qi -
tar xvzf blackbox_exporter-*.tar.gz
cd blackbox_exporter-*.linux-amd64
cp blackbox_exporter /usr/local/bin
chown prometheus:prometheus /usr/local/bin/blackbox_exporter
mkdir -p /etc/blackbox
cp blackbox.yml /etc/blackbox
chown -R prometheus:prometheus /etc/blackbox/*


cat <<EOF > /etc/systemd/system/blackbox.service
[Unit]
Description=Blackbox Exporter Service
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/blackbox_exporter \
  --config.file=/etc/blackbox/blackbox.yml \
  --web.listen-address="0.0.0.0:9115"

Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable blackbox
systemctl start blackbox

firewall-cmd --add-port=9115/tcp --permanent
firewall-cmd --reload