#!/bin/bash
set -e

STATE_DIR=/data/acme_state
CONFIG_PATH=/data/options.json

export TF_INPUT=0
export TF_DATA_DIR='/data/tf_working'

export TF_VAR_email=$(jq --raw-output ".email" $CONFIG_PATH)
export TF_VAR_common_name=$(jq --raw-output ".common_name" $CONFIG_PATH)
export TF_VAR_dns_names=$(jq --raw-output ".domains" $CONFIG_PATH)
export TF_VAR_staging=$(jq --raw-output ".staging" $CONFIG_PATH)

export AWS_ACCESS_KEY_ID=$(jq --raw-output ".aws_access_key_id" $CONFIG_PATH)
export AWS_SECRET_ACCESS_KEY=$(jq --raw-output ".aws_secret_access_key" $CONFIG_PATH)
export AWS_DEFAULT_REGION='us-east-1'


mkdir -p "${STATE_DIR}" "${TF_DATA_DIR}"

function update_certs(){
  terraform init -backend-config="path=${STATE_DIR}/acme.tfstate"
  terraform apply -auto-approve
  chmod 0644 "/ssl/fullchain.pem" "/ssl/privkey.pem"
}

while true; do
  update_certs
  sleep '2d'
done
