set -x
RANCHER_URL=
RANCHER_API_AUTH=
LOCAL_CONTEXT=local
MIN_CLUSTER_ID=1
MAX_CLUSTER_ID=100



for CLUSTER_ID in {seq $MIN_CLUSTER_ID $MAX_CLUSTER_ID}
do

cat << EOF | kubectl --context $LOCAL_CONTEXT apply -f -
kind: Cluster
apiVersion: provisioning.cattle.io/v1
metadata:
  name: cluster-$CLUSTER_ID
  namespace: fleet-default
  labels:
    cluster-id: "cluster-$CLUSTER_ID"
spec: {}
EOF

k3d cluster create --api-port 0.0.0.0:7$CLUSTER_ID cluster-$CLUSTER_ID

REG_TOKEN_LINK=`curl --user $RANCHER_API_AUTH $RANCHER_URL/v3/clusters?name=cluster-$CLUSTER_ID |jq ".data[0].links.clusterRegistrationTokens" -r`

IMPORT_YAML_URL=$RANCHER_URL/v3/import/`curl --user $RANCHER_API_AUTH $REG_TOKEN_LINK |jq '[.data[0].token, .data[0].clusterId ] | join("_")' -r`.yaml

kubectl apply --context k3d-store-$CLUSTER_ID -f $IMPORT_YAML_URL

done
