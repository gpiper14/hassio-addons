#!/bin/bash
set -e

CERT_DIR=/data/letsencrypt
CONFIG_PATH=/data/options.json

export TF_INPUT=0
export TF_DATA_DIR='/data/tf_working'

export TF_VAR_email=$(jq --raw-output ".email" $CONFIG_PATH)
epxort TF_VAR_dns_names=$(jq --raw-output ".domains" $CONFIG_PATH)
export TF_VAR_key_file=$(jq --raw-output ".keyfile" $CONFIG_PATH)
export TF_VAR_cert_file=$(jq --raw-output ".certfile" $CONFIG_PATH)
export TF_VAR_staging=$(jq --raw-output ".staging" $CONFIG_PATH)

export AWS_ACCESS_KEY_ID=$(jq --raw-output ".aws_access_key_id" $CONFIG_PATH)
export AWS_SECRET_ACCESS_KEY=$(jq --raw-output ".aws_secret_access_key" $CONFIG_PATH)
export AWS_DEFAULT_REGION='us-east-1'

mkdir -p "$CERT_DIR" "${TF_DATA_DIR}"

terraform init
terraform apply

chmod 0644 "${TF_VAR_cert_file}" "${TF_VAR_key_file}"


