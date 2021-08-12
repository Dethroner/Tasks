#!/bin/bash

yum install -y java-11-openjdk-devel curl

cat <<EOF | sudo tee /etc/yum.repos.d/elasticsearch.repo
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
yum clean all && yum makecache
yum update -y

yum install -y elasticsearch
yes | cp -rf /vagrant/files/e/* /etc/elasticsearch
systemctl daemon-reload
systemctl enable --now elasticsearch

yum install -y kibana
yes | cp -rf /vagrant/files/k/* /etc/kibana
systemctl daemon-reload
systemctl enable --now kibana
firewall-cmd --add-port=5601/tcp --permanent
firewall-cmd --reload


echo "root            soft    nofile  65536" >> /etc/security/limits.conf
echo "root            hard    nofile  65536" >> /etc/security/limits.conf
echo "*               soft    nofile  65536" >> /etc/security/limits.conf
echo "*               hard    nofile  65536" >> /etc/security/limits.conf

cat >> /etc/sysctl.conf << 'EOL'
net.core.somaxconn = 1024
net.core.netdev_max_backlog = 5000
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_wmem = 4096 12582912 16777216
net.ipv4.tcp_rmem = 4096 12582912 16777216
net.ipv4.tcp_max_syn_backlog = 8096
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 10240 65535
EOL

sysctl -p

curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent4.sh | sh
systemctl enable --now td-agent
td-agent-gem install fluent-plugin-elasticsearch
yes | cp -rf /vagrant/files/f/fluent.conf /etc/td-agent/td-agent.conf
systemctl restart td-agent
firewall-cmd --add-port=24224/{tcp,udp} --permanent
firewall-cmd --reload