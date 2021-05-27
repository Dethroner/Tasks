#!/bin/bash

yum install -y gcc gcc-c++ curl git pcre-devel httpd-tools

mkdir -p \
    /home/vagrant/nginx/sbin \
    /home/vagrant/nginx/conf \
    /home/vagrant/nginx/logs \
    /home/vagrant/nginx/client_body_temp\
    /home/vagrant/nginx/proxy_temp \
    /home/vagrant/nginx/fastcgi_temp \
    /home/vagrant/nginx/uwsgi_temp \
    /home/vagrant/nginx/scgi_temp \
    /home/vagrant/nginx/conf/vhosts

cd /tmp
curl -O https://nginx.org/download/nginx-1.20.0.tar.gz
tar xf nginx-*tar.gz
curl -O https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz
tar xf pcre-*tar.gz
curl -O http://artfiles.org/openssl.org/source/old/1.0.2/openssl-1.0.2u.tar.gz
tar xf openssl-*tar.gz
wget https://github.com/vozlt/nginx-module-vts/archive/v0.1.18.tar.gz
tar xf v0.1.18.tar.gz

cd /tmp/nginx-1.20.0
./configure \
    --prefix=/home/vagrant/nginx \
    --sbin-path=/home/vagrant/nginx/sbin/nginx \
    --conf-path=/home/vagrant/nginx/conf/nginx.conf \
    --error-log-path=/home/vagrant/nginx/logs/error.log \
    --http-log-path=/home/vagrant/nginx/logs/access.log \
    --pid-path=/home/vagrant/nginx/logs/nginx.pid \
    --user=vagrant \
    --group=vagrant \
    --with-http_ssl_module \
    --with-http_realip_module \
    --without-http_gzip_module \
    --add-dynamic-module=/tmp/nginx-module-vts-0.1.18 \
    --with-pcre=/tmp/pcre-8.44 \
    --with-openssl=/tmp/openssl-1.0.2u

make && make install

cat <<EOF > /etc/systemd/system/nginx.service
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/home/vagrant/nginx/logs/nginx.pid

ExecStartPre=/usr/bin/rm -f /home/vagrant/nginx/logs/nginx.pid
ExecStartPre=/home/vagrant/nginx/sbin/nginx -t
ExecStartPre=/usr/bin/chown -R vagrant:vagrant /home/vagrant/nginx
ExecStart=/home/vagrant/nginx/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true

User=vagrant
Group=vagrant
UMask=0007

[Install]
WantedBy=multi-user.target
EOF

tar xf /vagrant/html.tar.gz -C /home/vagrant/nginx/

cat <<EOF > /home/vagrant/nginx/conf/nginx.conf
user       vagrant;
worker_processes  5;

load_module modules/ngx_http_vhost_traffic_status_module.so;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

    vhost_traffic_status_zone;
    include /home/vagrant/nginx/conf/vhosts/*.conf;

}
EOF

cat <<EOF > /home/vagrant/nginx/conf/vhosts/backend.conf
server {
    listen       192.168.56.10:8080;
    server_name  _;

    location / {
       root   html;
       index  index.html index.htm;
    }

    location ~^/status {
       vhost_traffic_status_display;
       vhost_traffic_status_display_format html;
    }

    location /admin {
        auth_basic "Restricted area";
        auth_basic_user_file /home/vagrant/nginx/conf/.htpasswd;
        try_files   \$uri /admin.html;
    }

    location ~* /pictures/ {
        root html/resources;
    }

    error_page   404  /404.html;
    location = /404.html {
        root   html;
    }
}

EOF

touch /home/vagrant/nginx/conf/.htpasswd
htpasswd -b -c /home/vagrant/nginx/conf/.htpasswd admin nginx
systemctl enable nginx