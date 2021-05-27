#!/bin/bash

country=BY
state=Minsk
city=Minsk
org= Test Corp.
ou=IT
cn=LB
email=admin@test.lan
pass=P@ssw0rd

yum install -y gcc gcc-c++ curl git pcre-devel httpd-tools iptables-services openssl

mkdir -p \
    /home/vagrant/nginx/sbin \
    /home/vagrant/nginx/conf \
    /home/vagrant/nginx/logs \
    /home/vagrant/nginx/client_body_temp\
    /home/vagrant/nginx/proxy_temp \
    /home/vagrant/nginx/fastcgi_temp \
    /home/vagrant/nginx/uwsgi_temp \
    /home/vagrant/nginx/scgi_temp \
    /home/vagrant/nginx/conf/vhosts \
    /home/vagrant/nginx/ssl \
    /home/vagrant/nginx/conf/upstreams

cd /home/vagrant/nginx/ssl
openssl genrsa -des3 -passout pass:$pass -out server.key 2048 -noout
openssl req -new -key server.key -out server.csr -passin pass:$pass \
    -subj "/C=$country/ST=$state/L=$city/O=$org/OU=$ou/CN=$cn/emailAddress=$email"
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt -passin pass:$pass
echo $pass > /home/vagrant/nginx/ssl/ssl_password
chmod 700 /home/vagrant/nginx/ssl
chmod 600 /home/vagrant/nginx/ssl/server.*

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
    
    ssl_password_file /home/vagrant/nginx/ssl/ssl_password;

    vhost_traffic_status_zone;
    
    include /home/vagrant/nginx/conf/upstreams/*.conf;
    include /home/vagrant/nginx/conf/vhosts/*.conf;

}
EOF

cat <<EOF > /home/vagrant/nginx/conf/upstreams/web.conf
upstream backend {
    server 192.168.56.11:8080 weight=1;
    server 192.168.56.12:8080 weight=3;
}
EOF

cat <<EOF > /home/vagrant/nginx/conf/vhosts/lb.conf
server {
    listen       8080;
    return 301 https://\$host\$request_uri;
}

server {
    listen       8443 ssl;
    server_name  192.168.56.10;

    ssl_certificate /home/vagrant/nginx/ssl/server.crt;
    ssl_certificate_key /home/vagrant/nginx/ssl/server.key;

    location ~^/status {
        allow  192.168.56.1;
        deny   all; 
        vhost_traffic_status_display;
        vhost_traffic_status_display_format html;
    }

    proxy_intercept_errors on;
    error_page 404 https://\$host/err.html; # https://en.wikipedia.org/wiki/HTTP_404; 

    location / {
        proxy_pass http://backend;
    }

}
EOF

chown -R vagrant:vagrant /home/vagrant/nginx
systemctl enable nginx
systemctl start nginx

iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8443
systemctl enable iptables
service iptables save