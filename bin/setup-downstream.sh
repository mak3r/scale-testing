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

	ssh -o StrictHostKeychecking=no ec2-user@$DOWNIP "/bin/bash -s" < bin/install-k3s.sh
	ssh ec2-user@$DOWNIP "/bin/bash -s" < bin/install-helm.sh
	ssh ec2-user@$DOWNIP "/bin/bash -s" < bin/install-vcluster.sh
	scp bin/cluster-ops.sh ec2-user@$DOWNIP:~/.
	scp bin/scale-test.sh ec2-user@$DOWNIP:~/.
	scp bin/test.sh ec2-user@$DOWNIP:~/.
	ssh ec2-user@$DOWNIP "sudo cp cluster-ops.sh /usr/local/bin/." 
	ssh ec2-user@$DOWNIP "sudo cp scale-test.sh /usr/local/bin/." 
	ssh ec2-user@$DOWNIP "sudo cp test.sh /usr/local/bin/." 

	# Start a screen and build the clusters in the background
	ssh ec2-user@$DOWNIP screen -dmS "vc"
	ssh ec2-user@$DOWNIP screen -r "vc" -X "source /usr/local/bin/test.sh"
	ssh ec2-user@$DOWNIP screen -r "vc" -X "create-n $END $START $ACCESS_TOKEN"
}

for i in "${!DIP[@]}"
do 
	install-downstreams "${DIP[$i]}" $i $TOKEN; 
done

