#!/bin/bash

yum install -y java-11-openjdk httpd httpd-devel curl

JAVAP="/usr/lib/jvm/java-11-openjdk-11.0.11.0.9-1.el7_9.x86_64"
export JAVA_HOME=$JAVAP
export PATH=$PATH:$JAVAP/bin

groupadd tomcat
useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
echo "P@ssw0rd" | passwd --stdin tomcat

cd /tmp
curl -O https://downloads.apache.org/tomcat/tomcat-10/v10.0.6/bin/apache-tomcat-10.0.6.tar.gz
mkdir -p /opt/tomcat/
tar xzvf apache-tomcat-10*tar.gz -C /opt/tomcat --strip-components=1

cd /opt/tomcat
chgrp -R tomcat /opt/tomcat
chmod -R g+r conf
chmod g+x conf
chown -R tomcat webapps/ work/ temp/ logs/

cat <<EOF | tee /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=$JAVAP
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sed -i '103 i <Connector protocol="AJP/1.3" port="8009" redirectPort="8443" address="0.0.0.0" secretRequired="false" />' /opt/tomcat/conf/server.xml

sed -i '44 i <user username="admin" password="P@ssw0rd" roles="manager-gui,admin-gui"/>' /opt/tomcat/conf/tomcat-users.xml
sed -i '21 i <!--' /opt/tomcat/webapps/manager/META-INF/context.xml
sed -i '25 i -->' /opt/tomcat/webapps/manager/META-INF/context.xml
sed -i '21 i <!--' /opt/tomcat/webapps/host-manager/META-INF/context.xml
sed -i '25 i -->' /opt/tomcat/webapps/host-manager/META-INF/context.xml

cp /vagrant/clusterjsp.war /opt/tomcat/webapps/
chown -R tomcat /opt/tomcat/webapps/

systemctl daemon-reload
systemctl enable tomcat
systemctl start tomcat
systemctl status tomcat
