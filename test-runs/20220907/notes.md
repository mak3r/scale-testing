# 20220907 Test Run

* Request for 3k clusters
    * 2 nodes sql backed Rancher
    * 30 t3a.2xlarge instances downstream
    * request 100 virutual clusters @ downstream
    
* Total clusters created before Rancher collapsed: ~450

## Process notes
* K3s instances were created in a linear manner. Meaning each instance had to completely finish installing software (git, make, jq) and associated scripts for scale testing before virtual cluster creation could begin on that downstream cluster. 
* Once the instance was up an running virtual clusters were created in a background job. 
* No downstream reached the max 100 virtual clusters
* Since the job was backgrounded, the next instance and set of virtual clusters could begin.

* Consider putting timestamps on the output lines in timings.txt so that we can correlate when the failure actually began to affect all systems.

* Eventually the Rancher cluster just simply died and we could no longer ssh into the instance to check on it.

## Resource consumption of Virtual Cluster on each instance

* Resources utilized were far greater than anticipated
* **Check that the requests and limits are in fact being used.**

`kubectl top pods -A`
*SAMPLE OUTPUT:*
```
vcluster-vcluster0101   cattle-cluster-agent-55c45bcf44-stdzf-x-cattle-syste-fc80a94e3a   6m           356Mi           
vcluster-vcluster0101   coredns-669fb9997d-tg9tn-x-kube-system-x-vcluster0101             3m           23Mi            
vcluster-vcluster0101   fleet-agent-55b948fdd7-kgnjd-x-cattle-fleet-system-x-db339c854d   2m           44Mi            
vcluster-vcluster0101   vcluster0101-0                                                    89m          559Mi           
vcluster-vcluster0102   cattle-cluster-agent-69b977d7c-dc2fn-x-cattle-system-4912d1a70d   16m          414Mi           
vcluster-vcluster0102   coredns-669fb9997d-8tkgd-x-kube-system-x-vcluster0102             2m           21Mi            
vcluster-vcluster0102   fleet-agent-55b948fdd7-mj7wz-x-cattle-fleet-system-x-a4588273eb   2m           35Mi            
vcluster-vcluster0102   vcluster0102-0                                                    77m          593Mi           
vcluster-vcluster0103   cattle-cluster-agent-7574f4789c-qbdmx-x-cattle-syste-5b42c4a8ae   5m           345Mi           
vcluster-vcluster0103   coredns-669fb9997d-ckfmh-x-kube-system-x-vcluster0103             2m           25Mi            
vcluster-vcluster0103   fleet-agent-55b948fdd7-g5cvs-x-cattle-fleet-system-x-ff4cc77352   2m           39Mi            
vcluster-vcluster0103   vcluster0103-0                                                    74m          528Mi           
vcluster-vcluster0104   cattle-cluster-agent-759ffdc7dc-gjscr-x-cattle-syste-c670bb0b80   5m           347Mi           
vcluster-vcluster0104   coredns-669fb9997d-wv42g-x-kube-system-x-vcluster0104             2m           26Mi            
vcluster-vcluster0104   fleet-agent-55b948fdd7-gl7sr-x-cattle-fleet-system-x-89ac73e21a   2m           39Mi            
vcluster-vcluster0104   vcluster0104-0                                                    104m         526Mi           
...
```

## Code to pull and merge timings files
```
source bin/get-env.sh
for i in ${!DIP[@]}; do outfile=timings$(printf "%04d" $i).txt; scp ec2-user@${DIP[i]}:~/scale-testing/timings.txt "$outfile"; done
head -1 timings0001.txt >> timings.txt; for file in $(ls -1); do cat $file | sed -e '$s/$/\n/' | tail -n +2 >> timings.txt; done
```