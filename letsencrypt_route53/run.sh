#!/bin/bash
set -e

CERT_DIR=/data/letsencrypt
WORK_DIR=/data/workdir
CONFIG_PATH=/data/options.json

EMAIL=$(jq --raw-output ".email" $CONFIG_PATH)
DOMAINS=$(jq --raw-output ".domains[]" $CONFIG_PATH)
KEYFILE=$(jq --raw-output ".keyfile" $CONFIG_PATH)
CERTFILE=$(jq --raw-output ".certfile" $CONFIG_PATH)
STAGING=$(jq --raw-output ".staging" $CONFIG_PATH)
CHALLENGE=$(jq --raw-output ".challenge" $CONFIG_PATH)

export AWS_ACCESS_KEY_ID=$(jq --raw-output ".aws.aws_access_key_id" $CONFIG_PATH)
export AWS_SECRET_ACCESS_KEY=$(jq --raw-output ".aws.aws_secret_access_key" $CONFIG_PATH)

if [ "${STAGING}" == 'true' ]; do
    STAGING_ARG='--staging'
fi

if [ "${CHALLENGE}" == 'dns' ]; do
    ROUTE53_ARG='--dns-route53'
fi

mkdir -p "$CERT_DIR"

# Generate new certs
if [ ! -d "$CERT_DIR/live" ]; then
    DOMAIN_ARR=()
    for line in $DOMAINS; do
        DOMAIN_ARR+=(-d "$line")
    done

    echo "$DOMAINS" > /data/domains.gen
    certbot certonly --non-interactive --standalone --email "$EMAIL" --agree-tos ${STAGING_ARG} ${ROUTE53_ARG} --config-dir "$CERT_DIR" --work-dir "$WORK_DIR" --preferred-challenges "${CHALLENGE}" "${DOMAIN_ARR[@]}"

# Renew certs
else
    certbot renew --non-interactive ${STAGING_ARG} ${ROUTE53_ARG} --config-dir "$CERT_DIR" --work-dir "$WORK_DIR" --preferred-challenges "${CHALLENGE}"
fi

# copy certs to store
cp "$CERT_DIR"/live/*/privkey.pem "/ssl/$KEYFILE"
cp "$CERT_DIR"/live/*/fullchain.pem "/ssl/$CERTFILE"
