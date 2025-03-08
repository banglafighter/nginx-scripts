#!/bin/bash

echo "Installing Certbot"
dnf install -y epel-release
dnf install -y certbot python3-certbot-nginx

echo "Configuring Certbot"
certbot --version
systemctl enable certbot.timer --now



echo "Adding Auto Renew Script for Certbot"

# Define the cron job command
CERTBOT_CRON="0 */12 * * * certbot renew --quiet && systemctl reload nginx"

# Check if the cron job already exists
crontab -l | grep -F "$CERTBOT_CRON" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Certbot renewal cron job already exists. No changes made."
else
    # Add the cron job dynamically
    (crontab -l 2>/dev/null; echo "$CERTBOT_CRON") | crontab -
    echo "Certbot renewal cron job added successfully."
fi


# Log File
# cat /var/log/letsencrypt/letsencrypt.log