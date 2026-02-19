# Testing Rancher at Scale

* How many clusters can we attach to Rancher before it tips over?
* Are there differences in the max capability based on the backend etcd vs sql


## Test Plan General

* Test with etcd backend
* Test with sql backend
* Use sql testing as a baseline
* Test with imported k3d clusters
* Test with Rancher generated clusters
    * Test with type 2 hypervisor to avoid massive expense

### SQL testing 
a) Use hosted rancher
b) Use generic rancher backed by sql


* Hosted Rancher 
    * is backed by sql
    * is using RDS (what size backend, iops, etc)

* Test with a similar k3s but not hosted rancher


### Etcd testing

* Test with k3s embedded etcd

* Split etcd into it's own server (so it's not in contention with anything else on the server)
* 


## Ebedded Etcd vs RDS

### Known challenges
1. Scale # clusters to >2K
    * With >2K clusters how many git repos pushing to clusters function

1. Create >300k project role bindings 

### Setup 

* Terraform for AWS infra/RDS/LB
* Automate k3d cluster create and import
