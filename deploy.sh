#! /usr/bin/env bash

USAGE="
Usage:
  PLAN:  ./deploy.sh plan <fp_context> <domain>
  APPLY: ./deploy.sh apply <fp_context> <domain>
"

if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
  echo "$USAGE"
  exit 1
fi


action=$1
fp_context=$2
domain=$3
export TF_VAR_fp_context=$fp_context
export TF_VAR_domain=$domain

. $fp_context.env

cat << EOF > backend.tf
terraform {
  backend "s3" {
    region = "us-east-1"
    bucket = "fp-${fp_context}-terraform-state"
    key    = "infrastructure.tfstate"
  }
}
EOF

terraform init

if [[ "$action" == "plan" ]]; then
  terraform validate
  terraform plan
elif [[ "$action" == "apply" ]]; then
  terraform apply -auto-approve
else
  echo "Invalid action $action"
fi
