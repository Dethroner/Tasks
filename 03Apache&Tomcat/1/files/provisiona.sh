#!/bin/bash

yum update -y
yum install -y java-11-openjdk httpd httpd-devel curl

systemctl stop firewalld

#alternatives --config java
JAVAP="/usr/lib/jvm/java-11-openjdk-11.0.11.0.9-1.el7_9.x86_64"
export JAVA_HOME=$JAVAP
export PATH=$PATH:$JAVAP/bin

# Install mod_jk
cd /tmp
curl -O https://downloads.apache.org/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.48-src.tar.gz
tar xzvf tomcat-connectors* -C /usr/src
cd /usr/src/tomcat-connectors-1.2.48-src/native/
LDFLAGS=-lc ./configure -with-apxs=/usr/bin/apxs
make
cp ./apache-2.0/mod_jk.so /etc/httpd/modules

#
cat <<EOF | tee /etc/httpd/conf/workers.properties
worker.list=loadbalancer,status
worker.master.type=ajp13
worker.master.host=192.168.1.20
worker.master.port=8009
worker.master.ping_mode=A
worker.master.lbfactor=1


worker.slave.type=ajp13
worker.slave.host=192.168.1.20
worker.slave.port=8010
worker.slave.ping_mode=A
worker.slave.lbfactor=1


worker.loadbalancer.type=lb
worker.loadbalancer.balance_workers=master,slave
worker.loadbalancer.sticky_session=1

worker.status.type=status
EOF

cat <<EOT >> /etc/httpd/conf/httpd.conf
Include conf/mod-jk.conf
EOT

cat <<EOF | tee /etc/httpd/conf/mod-jk.conf
LoadModule jk_module modules/mod_jk.so
JkWorkersFile conf/workers.properties
JkShmFile logs/jk.shm
JkLogFile logs/mod_jk.log
JkLogLevel info
JkLogStampFormat "[%a %b %d %H:%M:%S %Y] "
JkOptions +ForwardKeySize +ForwardURICompat -ForwardDirectories 

JkMountFile conf/uriworkermap.properties

JkMount /clusterjsp/* loadbalancer

<Location /stat/>
    JkMount status
    Order deny,allow
    Deny from all
    Allow from 127.0.0.1
</Location>
EOF

cat <<EOF | tee /etc/httpd/conf/uriworkermap.properties
/*=loadbalancer
EOF

systemctl enable httpd
