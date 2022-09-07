#!/bin/bash -x


###############
# This script can be sourced to provide functions for 
# Building virtual clusters and connecting them to a Rancher Management Server
# The targeted downstream cluster is expected to be a single node cluster at this time.
###############
source /usr/local/bin/cluster-ops.sh

# Check that requirements are available
function check-config() {
  executable=$1
  e=$(command -v $executable)
  if [ -z "$e" ]; then echo "[FAIL]: $executable not found"; else echo "[SUCCESS]: $e"; fi
}

function scale-test-deps-check() {
	check-config "vcluster"
	check-config "terraform"
	check-config "kubectl"
	check-config "helm"
	check-config "make"
	check-config "jq"
}

# Get baselines for CPU and RAM
## Get memory usage
function memory-usage() {
  kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes" | jq '.items[0].usage.memory'
}

## Get CPU usage
function cpu-usage() {
  kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes" | jq '.items[0].usage.cpu'
}


# Create a virtual cluster
function new-cluster() {
  CLUSTER_NAME=$1
  INIT_COMMAND=$(create-cluster $CLUSTER_NAME)
  $INIT_COMMAND | sed 's/\(^.*$\)/    \1/g' | cat ./vcluster.yaml templates/vcluster-init-head.yaml - > $CLUSTER_NAME.yaml
  vcluster create $CLUSTER_NAME -f $CLUSTER_NAME.yaml --distro k3s --expose-local --connect=false
  rm $CLUSTER_NAME.yaml
}

# Create a cluster in Rancher

# Import the virtual cluster

# Check that the cluster is imported and visibile via Rancher

# If CPU and RAM are not at threshold, create another cluster
