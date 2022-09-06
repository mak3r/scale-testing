set -x
RANCHER_URL=
RANCHER_API_AUTH=
LOCAL_CONTEXT=local
MIN_CLUSTER_ID=100
MAX_CLUSTER_ID=200

SKIP_IMPORT=false

CLUSTER_LIST=`seq $MIN_CLUSTER_ID $MAX_CLUSTER_ID`



for CLUSTER_ID in $CLUSTER_LIST
do

if [[ $SKIP_IMPORT != "true" ]]
then

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

fi

k3d cluster create --api-port 0.0.0.0:7$CLUSTER_ID cluster-$CLUSTER_ID


if [[ $SKIP_IMPORT != "true" ]]
then

REG_TOKEN_LINK=`curl --user $RANCHER_API_AUTH $RANCHER_URL/v3/clusters?name=cluster-$CLUSTER_ID |jq ".data[0].links.clusterRegistrationTokens" -r`
IMPORT_YAML_URL=$RANCHER_URL/v3/import/`curl --user $RANCHER_API_AUTH $REG_TOKEN_LINK |jq '[.data[0].token, .data[0].clusterId ] | join("_")' -r`.yaml
kubectl apply --context k3d-store-$CLUSTER_ID -f $IMPORT_YAML_URL

fi

done
