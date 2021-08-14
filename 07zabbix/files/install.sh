#!/bin/bash

##################################################
DBROOTPASS=P@ssw0rd
DBNAME=zabbix
DBUSER=zabbix
DBPASS=zaq123

##################################################
dnf install -y epel-release && dnf update

### Zabbix 5.0 LTS version (supported until May, 2025)
setenforce 0 && sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config

rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/zabbix-release-5.0-1.el8.noarch.rpm
dnf clean all
dnf -y install zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-agent

##################################################
### Setup DB
dnf -y install mariadb-server php php-cli php-common php-mbstring php-mysqlnd php-xml php-bcmath php-devel php-pear php-gd && systemctl start mariadb && systemctl enable mariadb

##################################################
### Post-Install
#### set root password
# sudo /usr/bin/mysqladmin -u root password $DBROOTPASS
mysql_secure_installation <<EOF

y
$DBROOTPASS
$DBROOTPASS
y
n
y
y
EOF

##################################################
### Create zabbix DB
#### Create DBUSER
mysql -uroot -p$DBROOTPASS -e "CREATE USER '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASS';"
mysql -uroot -p$DBROOTPASS -e 'SELECT user,host,password FROM mysql.user;'
mysql -uroot -p$DBROOTPASS -e "SHOW GRANTS FOR '$DBUSER'@'localhost';"
#### Create DBNAME & select privilege for DBUSER
mysql -uroot -p$DBROOTPASS -e "CREATE DATABASE $DBNAME DEFAULT CHARACTER SET utf8 COLLATE utf8_bin;"
mysql -uroot -p$DBROOTPASS -e "GRANT ALL PRIVILEGES ON $DBNAME.* TO '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASS';"
mysql -uroot -p$DBROOTPASS -e "FLUSH PRIVILEGES"
mysql -uroot -p$DBROOTPASS -e "select user from mysql.db where db='$DBNAME';"
#### Import initial schema and data
mysql -uroot -p$DBROOTPASS $DBNAME -e "set global innodb_strict_mode='OFF';"
##### Zabbix 5.0 LTS version
zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -u$DBUSER -p$DBPASS $DBNAME
mysql -uroot -p$DBROOTPASS $DBNAME -e "set global innodb_strict_mode='ON';"
mysql -uroot -p$DBROOTPASS -e "SHOW TABLES FROM $DBNAME;"
#### Enter database password in Zabbix configuration file
sed -i '/# DBPassword=/c DBPassword=PASSWORD' /etc/zabbix/zabbix_server.conf
echo $DBPASS > pass
sed -i "s%PASSWORD%$(cat pass)%" /etc/zabbix/zabbix_server.conf
chmod -R 777 /var/run/zabbix
systemctl restart zabbix-server zabbix-agent
systemctl enable zabbix-server zabbix-agent
#### Configure firewall
firewall-cmd --add-service={http,https} --permanent
firewall-cmd --add-port={10051/tcp,10050/tcp} --permanent
firewall-cmd --reload

##################################################
### Configure Zabbix frontend
sed -i 's|; ||g' /etc/php-fpm.d/zabbix.conf
sed -i 's|Riga|Minsk|g' /etc/php-fpm.d/zabbix.conf
sed -i '/#ServerName www.example.com/c ServerName 127.0.0.1' /etc/httpd/conf/httpd.conf
systemctl restart httpd php-fpm
systemctl enable httpd php-fpm