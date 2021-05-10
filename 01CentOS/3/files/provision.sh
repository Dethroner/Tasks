#!/bin/bash

### 1
USER="Ruslan_Bykau"
groupadd -g 505 $USER
useradd $USER -u 505 -g 505 -m -d /home/$USER -s /bin/bash
echo "P@ssw0rd" | passwd --stdin "$USER"
#id $USER

### 2
groupadd -g 600 staff
useradd mongo -u 600 -g 600 -m -d /home/mongo -s /bin/bash
#id mongo

### 3
mkdir -p /apps/mongo
chmod 750 /apps/mongo
chown -R mongo:staff /apps/mongo
#ls -la /apps

### 4
mkdir -p /apps/mongodb
chmod 750 /apps/mongodb
chown -R mongo:staff /apps/mongodb
#ls -la /apps

### 5
mkdir -p /logs/mongo
chmod 740 /logs/mongo
chown -R mongo:staff /logs/mongo
#ls -la /logs

### 6
su -m mongo -c "cd /tmp;wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.6.5.tgz"
#ls -la /tmp | grep "mongo"

### 7
su -m mongo -c "cd /tmp;curl https://fastdl.mongodb.org/src/mongodb-src-r3.6.5.tar.gz -o mongodb-src-r3.6.5.tar.gz -s"
#ls -la /tmp | grep "mongo"

### 8
su -m mongo -c "cd /tmp;tar -xvzf mongodb-linux-x86_64-3.6.5.tgz"
#ls -la /tmp | grep "mongo"

### 9
su -m mongo -c "cp -a /tmp/mongodb-linux-x86_64-3.6.5/. /apps/mongo/"
ls -la /apps/mongo

### 10
su -m mongo -c "export PATH=/apps/mongo/bin:$PATH"

### 11
su -m mongo -c "echo 'export PATH=/apps/mongo/bin:$PATH' >> /home/mongo/.bash_profile"
su -m mongo -c "echo 'export PATH=/apps/mongo/bin:$PATH' >> /home/mongo/.bashrc"

### 12
echo "mongo soft nproc 32000" >> /etc/security/limits.d/20-nproc.conf
echo "mongo hard nproc 32000" >> /etc/security/limits.d/20-nproc.conf

### 13
echo "$USER  ALL=(mongo) NOPASSWD:/apps/mongo/bin/mongod" >> /etc/sudoers
echo "$USER  ALL=(root) NOPASSWD:/bin/systemctl" >> /etc/sudoers

### 14
cat <<EOF | tee /etc/mongod.conf
processManagement:
   fork: true
net:
   bindIp: 0.0.0.0
   port: 27017
storage:
   dbPath: /var/lib/mongo
systemLog:
   destination: file
   path: "/var/log/mongodb/mongod.log"
   logAppend: true
storage:
   journal:
      enabled: true
EOF

### 15
sed -i '10s!/var/log/mongodb!/logs/mongo!' /etc/mongod.conf
sed -i '7s!/var/lib/mongo!/apps/mongodb!' /etc/mongod.conf
#cat /etc/mongod.conf

### 16
cat <<EOF | tee /etc/systemd/system/mongod.service
[Unit]
Description=MongoDB Database Server
Documentation=https://docs.mongodb.org/manual
After=network-online.target
Wants=network-online.target
ConditionPathExists=/apps/mongo/bin/mongod

[Service]
User=mongo
Group=staff
EnvironmentFile=-/etc/sysconfig/mongod
ExecStart=/apps/mongo/bin/mongod -f /etc/mongod.conf
ExecStartPre=/usr/bin/mkdir -p /apps/mongo
ExecStartPre=/usr/bin/chown mongo:staff /apps/mongo
ExecStartPre=/usr/bin/chmod 750 /apps/mongo
ExecStartPre=/usr/bin/mkdir -p /apps/mongodb
ExecStartPre=/usr/bin/chown mongo:staff /apps/mongodb
ExecStartPre=/usr/bin/chmod 750 /apps/mongodb
PermissionsStartOnly=true
Type=forking

[Install]
WantedBy=multi-user.target
EOF

### 17
systemctl enable mongod
systemctl start mongod

### Check
echo "##################################################"
echo "###            Print mongod.log                ###"
echo "##################################################"
cat /logs/mongo/mongod.log | grep "[initandlisten]"
echo "##################################################"
systemctl status mongod
echo "##################################################"
echo "PID mongod:" $(pgrep -f mongod)
netstat -tulpan | grep "mongod"
