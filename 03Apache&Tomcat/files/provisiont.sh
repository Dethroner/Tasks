#!/bin/bash

# Install Java
apt update -y
apt install -y default-jdk curl
update-java-alternatives -l
JAVAP="/usr/lib/jvm/java-1.11.0-openjdk-amd64"
export JAVA_HOME=$JAVAP


# Create Tomcat User
groupadd tomcat
useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
echo "P@ssw0rd" | passwd --stdin tomcat

# Install Tomcat
cd /tmp
curl -O https://downloads.apache.org/tomcat/tomcat-10/v10.0.6/bin/apache-tomcat-10.0.6.tar.gz
mkdir -p /opt/tomcat/1 /opt/tomcat/2
tar xzvf apache-tomcat-10*tar.gz -C /opt/tomcat/1 --strip-components=1
cp -a /opt/tomcat/1/* /opt/tomcat/2/

for (( i=1; i <= 2; i++ ))
do

# Update Permissions
cd /opt/tomcat/$i
chgrp -R tomcat /opt/tomcat/$i
chmod -R g+r conf
chmod g+x conf
chown -R tomcat webapps/ work/ temp/ logs/

# Create a systemd Service File
cat <<EOF | tee /etc/systemd/system/tomcat$i.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=$JAVAP
Environment=CATALINA_PID=/opt/tomcat/$i/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat/$i
Environment=CATALINA_BASE=/opt/tomcat/$i
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/$i/bin/startup.sh
ExecStop=/opt/tomcat/$i/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

done

# Edit configs
sed -i '22s/port="8005"/port="8006"/' /opt/tomcat/2/conf/server.xml
sed -i '68s/port="8080"/port="8081"/' /opt/tomcat/2/conf/server.xml
sed -i '70s/redirectPort="8443"/redirectPort="8444"/' /opt/tomcat/2/conf/server.xml
sed -i '103 i <Connector protocol="AJP/1.3" port="8010" redirectPort="8444" />' /opt/tomcat/2/conf/server.xml
sed -i '103 i <Connector protocol="AJP/1.3" port="8009" redirectPort="8443" />' /opt/tomcat/1/conf/server.xml

# Configure Tomcat Web Management Interface
sed -i '44 i <user username="admin" password="P@ssw0rd" roles="manager-gui,admin-gui"/>' /opt/tomcat/1/conf/tomcat-users.xml
sed -i '21 i <!--' /opt/tomcat/1/webapps/manager/META-INF/context.xml
sed -i '25 i -->' /opt/tomcat/1/webapps/manager/META-INF/context.xml
sed -i '21 i <!--' /opt/tomcat/1/webapps/host-manager/META-INF/context.xml
sed -i '25 i -->' /opt/tomcat/1/webapps/host-manager/META-INF/context.xml

sed -i '44 i <user username="admin" password="P@ssw0rd" roles="manager-gui,admin-gui"/>' /opt/tomcat/2/conf/tomcat-users.xml
sed -i '21 i <!--' /opt/tomcat/2/webapps/manager/META-INF/context.xml
sed -i '25 i -->' /opt/tomcat/2/webapps/manager/META-INF/context.xml
sed -i '21 i <!--' /opt/tomcat/2/webapps/host-manager/META-INF/context.xml
sed -i '25 i -->' /opt/tomcat/2/webapps/host-manager/META-INF/context.xml

# Start tomcats
systemctl daemon-reload
systemctl enable tomcat1
systemctl enable tomcat2
systemctl start tomcat1
systemctl start tomcat2
systemctl status tomcat1
systemctl status tomcat2
