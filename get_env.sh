#!/usr/bin/env bash

$(terraform output -state=terraform-setup/terraform.tfstate -json rancher_cluster_ips | jq -r 'keys[] as $k | "export IP\($k)=\(.[$k])"')

export RDS_PRE="mysql://$(terraform output -state=terraform-setup/terraform.tfstate --raw sql_user):"
export RDS_POST="@$(terraform output -state=terraform-setup/terraform.tfstate --raw rds_endpoint)/\
$(terraform output -state=terraform-setup/terraform.tfstate --raw dbname)"

export URL="$(terraform output -state=terraform-setup/terraform.tfstate --raw url )"
