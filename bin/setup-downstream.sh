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
	ssh ec2-user@$DOWNIP "git clone https://github.com/mak3r/scale-testing.git"
	ssh ec2-user@$DOWNIP "cd scale-testing && bin/install-k3s.sh"
	ssh ec2-user@$DOWNIP "cd scale-testing && bin/install-helm.sh"
	ssh ec2-user@$DOWNIP "cd scale-testing && bin/install-vcluster.sh"
	ssh ec2-user@$DOWNIP "cd scale-testing && make install_scripts"
	
	# ssh ec2-user@$DOWNIP "/bin/bash -s" < bin/install-k3s.sh
	# ssh ec2-user@$DOWNIP "/bin/bash -s" < bin/install-helm.sh
	# ssh ec2-user@$DOWNIP "/bin/bash -s" < bin/install-vcluster.sh
	# scp bin/cluster-ops.sh ec2-user@$DOWNIP:~/.
	# scp bin/scale-test.sh ec2-user@$DOWNIP:~/.
	# scp bin/test.sh ec2-user@$DOWNIP:~/.
	# ssh ec2-user@$DOWNIP "sudo cp cluster-ops.sh /usr/local/bin/. && sudo chown ec2-user:users /usr/local/bin/cluster-ops.sh" 
	# ssh ec2-user@$DOWNIP "sudo cp scale-test.sh /usr/local/bin/. && sudo chown ec2-user:users /usr/local/bin/scale-test.sh"
	# ssh ec2-user@$DOWNIP "sudo cp test.sh /usr/local/bin/. && sudo chown ec2-user:users /usr/local/bin/test.sh"

	# Start a screen and build the clusters in the background
	# scp bin/build-cluster-group.sh ec2-user@$DOWNIP:~/. 
	ssh ec2-user@$DOWNIP "cd scale-testing && screen -dmS vc ./build-cluster-group.sh $END $START $ACCESS_TOKEN"
}

for i in "${!DIP[@]}"
do 
	if [ "$i" == "0"]; then
		install-downstreams "${DIP[$i]}" $i $TOKEN; 
	fi
done

