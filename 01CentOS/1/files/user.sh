#!/bin/bash

function user-provision() {
  local username=$1

  # Create user
  groupadd $username
  useradd -g $username -m -d /home/$username -c "$username user" -s /bin/bash $username 
  echo "P@ssw0rd" | passwd --stdin "$username"
  #chage -d 0 $username

  # Add an ssh key dir
  if [ ! -d "/home/$username/.ssh" ]; then
    mkdir /home/$username/.ssh
    chmod 700 /home/$username/.ssh
    chown $username:$username /home/$username/.ssh
  fi

  # Add the user to sudoers
  echo "$username  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

}

user-provision "$1"