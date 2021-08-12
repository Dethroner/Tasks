#!/bin/bash

PASS="P@ssword"

amazon-linux-extras install epel -y && yum install -y epel-release && yum update -y
yum install -y openldap openldap-servers openldap-clients
systemctl enable --now slapd

slappasswd -s ${PASS} > pass
cp -R /vagrant/files /tmp
sed -i "s%PASSWORD%$(cat pass)%" /tmp/files/ldaprootpasswd.ldif /tmp/files/ldapdomain.ldif /tmp/files/ldapuser.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/files/ldaprootpasswd.ldif

cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown -R ldap:ldap /var/lib/ldap/
systemctl restart slapd

ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/files/ldapdomain.ldif
ldapadd -w ${PASS} -x -D cn=Manager,dc=devopslab,dc=com -f /tmp/files/baseldapdomain.ldif
ldapadd -w ${PASS} -x -D cn=Manager,dc=devopslab,dc=com -f /tmp/files/ldapgroup.ldif
ldapadd -w ${PASS} -x -D cn=Manager,dc=devopslab,dc=com -f /tmp/files/ldapuser.ldif

yum install -y phpldapadmin

sed -i "397s%// %%" /etc/phpldapadmin/config.php
sed -i "398s%^%// %" /etc/phpldapadmin/config.php
sed -i "12 i     Require ip 192.168.1.0/24" /etc/httpd/conf.d/phpldapadmin.conf
systemctl enable httpd
systemctl restart httpd