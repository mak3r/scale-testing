#!/bin/sh


###############
# This script can be sourced to provide functions for 
# Building virtual clusters and connecting them to a Rancher Management Server
# The targeted downstream cluster is expected to be a single node cluster at this time.
###############
source cluster-ops.sh

RANCHER_URL=$1
CLUSTERS_PREFIX=$2

# Check that requirements are available
function check-config() {
  if command -v vcluster; then 
    echo 0
  else 
    echo 1 
  fi 
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
function create-cluster() {
  vcluster create $1 
}

# Create a cluster in Rancher

# Import the virtual cluster

# Check that the cluster is imported and visibile via Rancher

# If CPU and RAM are not at threshold, create another cluster
