#!/bin/bash

source bin/get-env.sh 
TOKEN=$1

function install-downstreams {
	echo $0
	echo $@
	DOWNIP=$1
	START=$(( ($2 * 100) + 1 ))
	END=$(( ($2+1) * 100 ))
	ACCESS_TOKEN=$3

	ssh -o StrictHostKeychecking=no ec2-user@$DOWNIP "sudo zypper -n in jq git make"	
	ssh ec2-user@$DOWNIP "git clone -b registered-clusters https://github.com/mak3r/scale-testing.git"
	ssh ec2-user@$DOWNIP "cd scale-testing && bin/install-k3s.sh"
	ssh ec2-user@$DOWNIP "cd scale-testing && bin/install-helm.sh"
	ssh ec2-user@$DOWNIP "cd scale-testing && bin/install-vcluster.sh"
	ssh ec2-user@$DOWNIP "cd scale-testing && make install_scripts"

	# Start a screen and build the clusters in the background
	scp bin/build-cluster-group.sh ec2-user@$DOWNIP:~/. 
	ssh ec2-user@$DOWNIP screen -dmS vc ./build-cluster-group.sh $END $START $ACCESS_TOKEN
}

for i in "${!DIP[@]}"
do 
	install-downstreams "${DIP[$i]}" $i $TOKEN
done

