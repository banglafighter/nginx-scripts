#!/bin/bash

echo "Installing Nginx"
dnf install nginx -y  # Install
systemctl enable --now nginx # Enable and start


echo "Adding Firewall"
setsebool -P httpd_can_network_connect 1 # Allow connect in SELinux

firewall-cmd --permanent --zone=public --add-service=http # Add 80 or http into firewall
firewall-cmd --permanent --zone=public --add-service=https # Add 443 or https into firewall
firewall-cmd --reload  # Reload the firewall


