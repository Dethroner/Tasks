#!/bin/bash 

useradd -M -r -s /bin/false node_exporter
cd /tmp
curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest \
| grep browser_download_url \
| grep linux-amd64 \
| cut -d '"' -f 4 \
| wget -qi -
tar -xvf node_exporter*.tar.gz
cd  node_exporter*/
cp node_exporter /usr/local/bin

cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter

# firewall-cmd --add-port=9100/tcp --permanent
# firewall-cmd --reload