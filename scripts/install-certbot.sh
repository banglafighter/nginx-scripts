#!/bin/bash

# Define systemd service and timer file paths
SERVICE_FILE="/etc/systemd/system/certbot-renew.service"
TIMER_FILE="/etc/systemd/system/certbot-renew.timer"

echo "Installing Certbot systemd timer for automatic SSL renewal..."

# Ensure Certbot is installed
if ! command -v certbot &> /dev/null; then
    echo "Certbot is not installed. Installing..."
    dnf install -y epel-release
  dnf install -y certbot python3-certbot-nginx
fi

# Create the systemd service file
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Renew Let's Encrypt Certificates
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/certbot renew --quiet
ExecStartPost=/bin/systemctl reload nginx  # Change to apache2 if using Apache
EOF

echo "Certbot service file created: $SERVICE_FILE"

# Create the systemd timer file
sudo bash -c "cat > $TIMER_FILE" <<EOF
[Unit]
Description=Run Certbot renewal twice daily

[Timer]
OnCalendar=*-*-* 00,12:00:00  # Runs at midnight and noon
Persistent=true

[Install]
WantedBy=timers.target
EOF

echo "Certbot timer file created: $TIMER_FILE"

# Reload systemd and enable the timer
sudo systemctl daemon-reload
sudo systemctl enable certbot-renew.timer
sudo systemctl start certbot-renew.timer

echo "Certbot systemd timer successfully installed and enabled."

# Check status
sudo systemctl list-timers --all | grep certbot-renew
