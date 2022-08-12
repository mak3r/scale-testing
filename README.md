# scale-testing
Scale testing cloud native

## Dependencies
1. Clone this repo
1. Install the scripts with `make install_scripts`
1. Load the script functions into the shell `source scale-test.sh`
1. Run `scale-test-deps-check` to see what is required

## Quick Start
### Build the Rancher infrastructure
```
make infrastructure
make k3s-install
make rancher
```

1. Login to the Rancher at the URL output by the last make command
1. Get and ACCESS_TOKEN for use when spinning up clusters

### Build a Downstream Cluster to Host VClusters
`make install_downstream_env`

### Spin up a Cluster and Connect It to Rancher
```
make install_scripts
source scale-test.sh
export RANCHER_HOST="scale-test.mak3r.design"
export ACCESS_TOKEN="token-v6twl:6c986bh4fnxd7zw2tdvlwlbtdr9xsj765tnttg66kbps4rdjchrl4z"
new-cluster <unique_cluster_name>
```
