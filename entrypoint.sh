#!/bin/sh

# Arguments to variables
CLOUDFLARE_API_TOKEN=$1
DOMAIN_NAME=$2
NOTIFICATION_EMAIL=$3
CERT_FILE_NAME=$4
DRY_RUN=$5

# Validating input variables
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "Please configure a valid Cloudflare DNS API Token"
    exit 1
fi
if [ -z "$DOMAIN_NAME" ]; then
    echo "Please provide a valid domain name to issue certificate"
    exit 1
fi
if [ -z "$NOTIFICATION_EMAIL" ]; then
    echo "Please provide a valid email address to set as notification email"
    exit 1
fi

# Preparing cloudflare credentials config file
mkdir -p /opt/cloudflare/
echo 'dns_cloudflare_api_token = '$CLOUDFLARE_API_TOKEN > /opt/cloudflare/credentials
chmod 600 /opt/cloudflare/credentials

CERTBOT_COMMAND="certbot certonly --non-interactive --cert-name issued_cert --dns-cloudflare --dns-cloudflare-credentials /opt/cloudflare/credentials --agree-tos --email $NOTIFICATION_EMAIL -d $(echo $DOMAIN_NAME | sed -e 's/,/ -d /g') --server https://acme-v02.api.letsencrypt.org/directory"

# check if certs file name does not ends with zip
if [[ $CERT_FILE_NAME != *.zip ]]; then
    CERT_FILE_NAME=$CERT_FILE_NAME.zip
fi

if [[ $DRY_RUN == "true" ]]; then
    # Performing a dry run
    echo "Performing a dry run"
    CERTBOT_COMMAND="$CERTBOT_COMMAND --dry-run"
    echo $CERTBOT_COMMAND | sh
    # Creating a dummy directory
    mkdir -p /etc/letsencrypt/archive/issued_cert/
    echo "mock cert for the domains $DOMAIN_NAME" > /etc/letsencrypt/archive/issued_cert/cert.pem
    echo "mock key for the domains $DOMAIN_NAME" > /etc/letsencrypt/archive/issued_cert/privkey.pem
    echo "mock chain for the domains $DOMAIN_NAME" > /etc/letsencrypt/archive/issued_cert/chain.pem
    echo "mock fullchain for the domains $DOMAIN_NAME" > /etc/letsencrypt/archive/issued_cert/fullchain.pem
else
    # Requesting for a certificate
    echo "Requesting for certificates"
    echo $CERTBOT_COMMAND | sh
fi

# Compiling certificates and keys to a zip archive
zip -j -r $CERT_FILE_NAME.zip /etc/letsencrypt/archive/issued_cert/