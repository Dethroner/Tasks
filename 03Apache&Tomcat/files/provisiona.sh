#!/bin/bash

apt update -y
apt install -y default-jdk apache2 apache2-dev curl
update-java-alternatives -l
JAVAP="/usr/lib/jvm/java-1.11.0-openjdk-amd64"
export JAVA_HOME=$JAVAP

# Install Tomcat
cd /tmp
curl -O https://downloads.apache.org/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.48-src.tar.gz
tar xzvf tomcat-connectors* -C /usr/src
cd /usr/src/tomcat-connectors-1.2.48-src/native/
LDFLAGS=-lc ./configure -with-apxs=/usr/bin/apxs
make
cp ./apache-2.0/mod_jk.so /usr/lib/apache2/modules

#
cat <<EOF | tee /etc/apache2/workers.properties
worker.list=master,slave,loadbalancer,jkstatus
worker.master.type=ajp13
worker.master.host=192.168.1.20
worker.master.port=8009
worker.master.lbfactor=1
worker.master.socket_timeout=0
worker.master.socket_keepalive=1
worker.master.connection_pool_timeout=60
worker.master.connection_pool_size=300
worker.master.connection_pool_minsize=50 

worker.slave.type=ajp13
worker.slave.host=192.168.1.20
worker.slave.port=8010
worker.slave.lbfactor=1
worker.slave.socket_timeout=0
worker.slave.socket_keepalive=1
worker.slave.connection_pool_timeout=60
worker.slave.connection_pool_size=300
worker.slave.connection_pool_minsize=50 

worker.loadbalancer.type=lb
worker.loadbalancer.balance_workers=master,slave
worker.loadbalancer.sticky_session=1

worker.jkstatus.type=status
EOF

cat <<EOT >> /etc/apache2/apache2.conf 
LoadModule jk_module /usr/lib/apache2/modules/mod_jk.so

JkWorkersFile /etc/apache2/workers.properties
logsJkLogFile /var/log/apache2/mod_jk.log
[debug/error/info]JkLogLevel info
JkLogStampFormat "[%a %b %d %H:%M:%S %Y] "
JkOptions +ForwardKeySize +ForwardURICompat -ForwardDirectories 
JkRequestLogFormat "%w %V %T"

JkMount /stat jkstatus
JkMount / loadbalancer
EOT

systemctl start apache2