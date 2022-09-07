#!/bin/bash -x

source /usr/local/bin/scale-test.sh

RANCHER_HOST="scale-test.mak3r.design"
CLUSTER_PREFIX="vcluster"
DATA_FILE="timings.txt"

function create-n() {
	END=$1
	START=$2
	ACCESS_TOKEN=$3 #"token-ctlhv:tgcf9vkooEXAMPLEoo9wsxr7bg2mbbq2j6hjm8vklp7k6g7nqf5p"
	HEADER="CLUSTER NAME\tCLUSTER CREATE TIME\tHOURS\tMINUTES\tSECONDS\tREADY TIME\tHOURS\tMINUTES\tSECONDS\tDURATION"
	PROCESS_BEGIN=$(date +%s)
	printf "$HEADER\n" >> $DATA_FILE
	for ((i=$START; i<$END; i++)); do
		cluster_name=$CLUSTER_PREFIX$(printf "%04d" $i)
		printf "$cluster_name" >> $DATA_FILE
		BEGIN=$(date +%s)
		new-cluster $cluster_name
		CREATE_TIME=$(($(date +%s)-$BEGIN))
		printf "\t$CREATE_TIME" >> $DATA_FILE
		printf "\t%d\t%d\t%d" $(date -d@$CREATE_TIME -u +%H) $(date -d@$CREATE_TIME -u +%M) $(date -d@$CREATE_TIME -u +%S) >> $DATA_FILE
		#Test the status of the created cluster before continuing
		READY="False"
		while [ "$READY" != "True" ]; do
			READY=$(curl -s -k -u "$ACCESS_TOKEN" https://$RANCHER_HOST/v1/provisioning.cattle.io.clusters/fleet-default/$cluster_name | jq -r '.status.conditions | map(select(.type == "Ready")) | .[].status')
			sleep 20
			ELAPSED=$(($(date +%s)-$BEGIN))
			if [[ $ELAPSED -gt 300 ]]; then 
				break
			fi
		done
		ELAPSED=$(($(date +%s)-$BEGIN))
		printf "\t$ELAPSED" >> $DATA_FILE
		printf "\t%d\t%d\t%d" $(date -d@$ELAPSED -u +%H) $(( 10#$(date -d@$ELAPSED -u +%M) )) $(( 10#$(date -d@$ELAPSED -u +%S) )) >> $DATA_FILE
		DURATION=$(($(date +%s)-$PROCESS_BEGIN))
		printf "\t$(date -d@$DURATION -u +%H:%M:%S)" >> $DATA_FILE
		printf "\n" >> $DATA_FILE
	done
}

function delete-n() {
	END=$1
	START=$2
	ACCESS_TOKEN=$3
	for ((i=$START; i<$END; i++)); do
		cluster_name=$CLUSTER_PREFIX$(printf "%02d" $i)
		#Delete from rancher
		curl -s -k -u "$ACCESS_TOKEN" -X DELETE  https://$RANCHER_HOST/v1/provisioning.cattle.io.clusters/fleet-default/$cluster_name > /dev/null
		#Delete from k8s
		vcluster delete $cluster_name; 
	done
}