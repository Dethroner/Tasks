#!/bin/bash

### Fix java
alternatives --config java <<<1
export JAVA_HOME=$(dirname $(dirname `readlink -f /etc/alternatives/java`))
export PATH=$JAVA_HOME/bin:$PATH
java -version

### Fix Tomcat
sed -i 's!> /dev/null! !g' /etc/init.d/tomcat
sed -i '/  su -c "init 6"/d' /etc/init.d/tomcat
sed -i 's!JAVA_HOME=/tmp!JAVA_HOME=/opt/oracle/java/x64/jdk1.7.0_80!g' /home/tomcat/.bashrc
sed -i 's!CATALINA_HOME=/tmp!CATALINA_HOME=/opt/apache/tomcat/7.0.82!g' /home/tomcat/.bashrc
chown -R tomcat:tomcat /opt/apache/tomcat/7.0.82
chmod +x /opt/apache/tomcat/7.0.82/bin/*.sh
sed -i 's!192.168.56.10!127.0.0.1!g' /opt/apache/tomcat/7.0.82/conf/server.xml
service tomcat start
systemctl enable tomcat

### Fix Apache
sed -i 's!^LoadModule authn_alias_module!#LoadModule authn_alias_module!g' /etc/httpd/conf/httpd.conf
sed -i 's!^LoadModule authn_default_module!#LoadModule authn_default_module!g' /etc/httpd/conf/httpd.conf
sed -i 's!^LoadModule authz_default_module!#LoadModule authz_default_module!g' /etc/httpd/conf/httpd.conf
sed -i 's!^LoadModule ldap_module!#LoadModule ldap_module!g' /etc/httpd/conf/httpd.conf
sed -i 's!^LoadModule authnz_ldap_module!#LoadModule authnz_ldap_module!g' /etc/httpd/conf/httpd.conf
sed -i 's!^LoadModule disk_cache_module!#LoadModule disk_cache_module!g' /etc/httpd/conf/httpd.conf
sed -i '/NameVirtualHost 0.0.0.0:80/d' /etc/httpd/conf/httpd.conf
sed -i '/DefaultType text\/plain/d' /etc/httpd/conf/httpd.conf

if grep -Fxq 'Include conf.modules.d/*.conf' /etc/httpd/conf/httpd.conf
then
    echo
else
    sed -i '43 i Include conf.modules.d/*.conf' /etc/httpd/conf/httpd.conf
fi

sed -i 's!Redirect "/" "http://mntlab/"!#Redirect "/" "http://mntlab/"!g' /etc/httpd/conf/httpd.conf
sed -i 's!^    ErrorDocument!#    ErrorDocument!g' /etc/httpd/conf/httpd.conf
sed -i 's!^<VirtualHost!#<VirtualHost!g' /etc/httpd/conf/httpd.conf
sed -i 's!^</VirtualHost!#</VirtualHost!g' /etc/httpd/conf/httpd.conf

sed -i 's!mntlab!*!g' /etc/httpd/conf.d/vhost.conf

sed -i 's/192.168.56.100/127.0.0.1/' /etc/httpd/conf.d/workers.properties
sed -i 's/worker-jk@ppname/tomcat.worker/g' /etc/httpd/conf.d/workers.properties
###
# pkill -f nc
# grep -R "nc -l 80" /usr/lib/systemd/
systemctl disable bindserver
service bindserver stop
###
service httpd start
systemctl enable httpd

### Edit iptable's chains
chattr -i /etc/sysconfig/iptables
cat <<EOF > /etc/sysconfig/iptables
# Generated by iptables-save v1.4.7 on Tue Jun 17 07:55:18 2014
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [71:8305]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOF
service iptables restart
chattr +i /etc/sysconfig/iptables