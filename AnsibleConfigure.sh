#!/bin/bash

# Prompt user for the desired username
read -p "Create username: " username
# Create the user
useradd -m $username
#Create an SSH directory for the user
mkdir /home/$username/.ssh
# Copy the public key to the user's authorized_keys file
echo "Paste the public key for $username and then press [ENTER]:"
read -r public_key
echo "$public_key" >> /home/$username/.ssh/authorized_keys

chmod 700 /home/$username/.ssh
chmod 600 /home/$username/.ssh/authorized_keys
chown -R $username:$username /home/$username/.ssh
# Add the user to the sudo group
usermod -aG sudo $username
# give the user the ability to become root by adding the following line to the /etc/sudoers file
echo "$username ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
echo "User $username has been created and added to the sudo group, with key-based authentication enabled and ability to become root"

#INSTALL ANSIBLE 
# Update package list
apt update
# Install Ansible
apt install -y ansible

sudo mkdir /etc/ansible
sudo touch /etc/ansible/hosts
echo "[servers]" | sudo tee -a /etc/ansible/hosts
echo "192.168.1.104" | sudo tee -a /etc/ansible/hosts

#RESOLVE DNS
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf


