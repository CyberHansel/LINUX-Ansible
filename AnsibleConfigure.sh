#!/bin/bash

# Prompt user for the desired username for ansible
read -p "Create username: " username
# Create the user
useradd -m $username
#Create an SSH directory for the user ansible
mkdir /home/$username/.ssh
# Copy the public key to the user's authorized_keys file In case if this ansible is not control node
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

#RESOLVE DNS This is for new systems, sometimes DNS is not configured.
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf

#INSTALL ANSIBLE 
# Update package list
apt update
# Install Ansible
apt install -y ansible

#Configure Ansible if there is no config.cfg file then create it
config_file="/etc/ansible/ansible.cfg"

# Check if file exists ancible.cfg
if [ ! -f "/etc/ansible/ansible.cfg" ]; then
    touch "$config_file"
fi

# Check if section already exists and add configuration
if grep -q "\[defaults\]" "/etc/ansible/ansible.cfg"; then
    # Update existing section
    # with SSL cert 5986 port
    #sed -i '/\[defaults\]/a transport = winrm\nremote_user = ansible\nansible_port = 5986\nansible_connection = credssp\ninventory = /etc/ansible/hosts' "/etc/ansible/ansible.cfg"
    
    # with no cert HTTP traffic 5985 port
    sed -i '/\[defaults\]/a transport = winrm\nremote_user = ansible\nansible_port = 5985\ninventory = /etc/ansible/hosts' "/etc/ansible/ansible.cfg"
else
    # Add new section
    # with SSL cert 5986 port
    #echo -e "\n[defaults]\ntransport = winrm\nremote_user = ansible\nansible_port = 5986\nansible_connection = credssp\ninventory = /etc/ansible/hosts" >> "/etc/ansible/ansible.cfg"
    
    # with no cert HTTP traffic 5985 port
    echo -e "\n[defaults]\ntransport = winrm\nremote_user = ansible\nansible_port = 5985\ninventory = /etc/ansible/hosts" >> "/etc/ansible/ansible.cfg"
fi
echo "Ansible configuration file updated successfully"


# Same configuration for inventory (host) file
inventory_file="/etc/ansible/hosts"
# Create inventory file if it doesn't exist
if [ ! -f "$inventory_file" ]; then
    touch "$inventory_file"
fi

# Check if windows group already exists in host file
if grep -q "\[windows\]" "$inventory_file"; then
    # Update existing group
    sed -i '/\[windows\]/a 192.168.1.103 ansible_user=ansible ansible_password=ansible ansible_port=5985 ansible_connection=winrm ansible_winrm_transport=basic' "$inventory_file"
else
    # Add new group
    echo -e "\n[windows]\n192.168.1.103 ansible_user=ansible ansible_password=ansible ansible_port=5985 ansible_connection=winrm ansible_winrm_transport=basic" >> "$inventory_file"
fi
echo "Inventory file updated successfully"

export ANSIBLE_CONFIG=~/Desktop/ansible.cfg
export ANSIBLE_INVENTORY=~/Desktop/hosts

Alternatively, you can add these lines to your shell profile file (e.g. .bashrc, .bash_profile, etc.) to persist the environment variables across terminal sessions.




