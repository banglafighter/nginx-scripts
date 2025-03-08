#!/bin/bash

get_input() {
    local var_name="$1"  # Variable name
    local prompt_msg="$2"  # Prompt message
    local default_value="$3"  # Default value (optional)

    # If variable is empty, prompt the user
    while [[ -z "${!var_name}" ]]; do
        read -rp "$prompt_msg: " input
        export $var_name="${input:-$default_value}"
    done
}

SERVER_NAME="${1:-}"
DOC_ROOT="${2:-}"

get_input SERVER_NAME "Enter server name"
get_input DOC_ROOT "Enter document root path"

FILE_NAME="/etc/nginx/conf.d/$SERVER_NAME.conf"
if [ -f "$FILE_NAME" ]; then
    echo "$FILE_NAME already exists."
    exit 1  # Exit with an error code
fi

CONFIG=$(cat <<EOF
server {
    listen 80;
    server_name $SERVER_NAME;

    index index.html;
    root $DOC_ROOT;
    default_type text/html;

    location / {
        try_files \$uri\$args \$uri\$args/ /index.html;
    }
}
EOF
)

echo "$CONFIG" >> $FILE_NAME
echo "Has bee created: $FILE_NAME"

if nginx -t; then
    echo "Nginx configuration is valid. Restarting Nginx..."
    systemctl restart nginx
    echo "Nginx restarted successfully."
else
    echo "Nginx configuration is invalid. Please fix the errors and try again."
    exit 1
fi