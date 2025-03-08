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

DOMAIN_NAME="${1:-}"

get_input DOMAIN_NAME "Enter domain name"
certbot --nginx -d $DOMAIN_NAME