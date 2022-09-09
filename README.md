# scale-testing
Scale testing cloud native

## Dependencies

* terraform
* helm
* jq
* kubectl
* aws
* dns address for Rancher

## Quick Start
### Prep
* `cp terraform-setup/terraform.tfvars.template terraform-setup/terraform.tfvars`
    * Adjust the tfvars variables as desired
* Set your aws account id and key using the terraform variables
    * `aws_access_key_id`
    * `aws_secret_access_key`
* See `variables.tf` for other infrastructure configuration 
* Make sure you have a registered domain
    * Use terraform variable `domain` to set it
    * Use terraform variable `rancher_url` to set the subdomain
    * fqdn is <rancher_url>.<domain>

### Build the Rancher infrastructure
```
make DOWNSTREAM_COUNT=3 infrastructure
make k3s-install
make rancher
```
The prior commands will create 2 infrastructure nodes for the rancher cluster and 3 nodes (using `DOWNSTREAM_COUNT` variable) for populating with virtual clusters

1. Login to Rancher at the URL output by the last make command
1. Get an ACCESS_TOKEN for use when spinning up clusters

### Build Downstream Clusters 
`make API_TOKEN="ab39g:4iooEXAMPLEooTOKENookj98z" downstream`

Using the access token you got from Rancher, the prior command will install k3s on the dowstream infrastructure and then begin installing vclusters based on the [bin/setup-downstream.sh](bin/setup-downstream.sh) script.

