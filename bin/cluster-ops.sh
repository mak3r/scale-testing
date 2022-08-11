#!/bin/bash

# multifunctional need to be globally scoped
RANCHER_HOST='rancher.url'
ACCESS_TOKEN='token-d2852:fwqzpdvsxp9f5mv965v6h9snvkr2z78hm9rsh28p4mqvqsg44gm2lf'

# takes argument of cluster name within rancher
function create-cluster() 
{
  CLUSTER_NAME=$1
  CLUSTER_NS='fleet-default'

  read -r -d '' CLUSTER_CONFIG <<-EOF
	{
	"metadata": {
		"name": "$CLUSTER_NAME",
		"namespace": "$CLUSTER_NS"
	},
	"spec": null,
	"status": null
	}
	EOF

  # Create the cluster
  curl -s -k -u "$ACCESS_TOKEN" -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -d "$CLUSTER_CONFIG" https://$RANCHER_HOST/v1/provisioning.cattle.io.clusters >/dev/null; 
  # Wait for object to init
  sleep 2;

  # Get cluster id
  CLUSTER_ID=$(curl -s -k -u "$ACCESS_TOKEN" https://$RANCHER_HOST/v1/provisioning.cattle.io.clusters/fleet-default/$CLUSTER_NAME | jq -r '.status.clusterName');

  # Get registration commands
  curl -s -k -u "$ACCESS_TOKEN" https://$RANCHER_HOST/v3/clusterregistrationtokens?clusterId=$CLUSTER_ID | jq -r '.data[] | {command, insecureCommand}';
}

# takes arguement of cluster name within rancher
function get_cluster_status ()
{
  CLUSTER_NAME=$1;
  CLUSTER_NS='fleet-default';
  curl -sk -u $ACCESS_TOKEN https://$RANCHER_HOST/v1/provisioning.cattle.io.clusters/$CLUSTER_NS/$CLUSTER_NAME | jq '.metadata.state';
}
  
