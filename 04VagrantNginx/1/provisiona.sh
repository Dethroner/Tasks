#!/bin/bash

yum install -y java-11-openjdk httpd httpd-devel curl

JAVAP="/usr/lib/jvm/java-11-openjdk-11.0.11.0.9-1.el7_9.x86_64"
export JAVA_HOME=$JAVAP
export PATH=$PATH:$JAVAP/bin

cd /tmp
curl -O https://downloads.apache.org/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.48-src.tar.gz
tar xzvf tomcat-connectors* -C /usr/src
cd /usr/src/tomcat-connectors-1.2.48-src/native/
LDFLAGS=-lc ./configure -with-apxs=/usr/bin/apxs
make
cp ./apache-2.0/mod_jk.so /etc/httpd/modules

cat <<EOF | tee /etc/httpd/conf/workers.properties
worker.list=loadbalancer,status
worker.node1.type=ajp13
worker.node1.host=192.168.56.21
worker.node1.port=8009
worker.node1.ping_mode=A
worker.node1.lbfactor=1

worker.node2.type=ajp13
worker.node2.host=192.168.56.22
worker.node2.port=8009
worker.node2.ping_mode=A
worker.node2.lbfactor=1

worker.loadbalancer.type=lb
worker.loadbalancer.balance_workers=node1,node2
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
</Location>
EOF

cat <<EOF | tee /etc/httpd/conf/uriworkermap.properties
/*=loadbalancer
EOF

systemctl enable httpd
systemctl start httpd
systemctl status httpd