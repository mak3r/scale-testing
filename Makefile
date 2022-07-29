SHELL := /bin/bash
K3S_TOKEN="mak3rVA87qPxet2SB8BDuLPWfU2xnPUSoETYF"
RANCHER_VERSION="2.6.4"
SERVER_NUM=-1
ADMIN_SECRET="6DfOqQMzaNFTg6VV"
K3S_CHANNEL=v1.20
K3S_UPGRADE_CHANNEL=v1.21
RANCHER_URL=scale-test
SQL_PASSWORD="Kw309ii9mZpqD"
export KUBECONFIG=kubeconfig

destroy:
	-rm kubeconfig
	cd terraform-setup && terraform destroy -auto-approve && rm terraform.tfstate terraform.tfstate.backup

sleep:
	sleep 60

infrastructure:
	echo "Creating infrastructure"
	cd terraform-setup && terraform init && terraform apply -auto-approve -var rancher_url=$(RANCHER_URL) -var db_password=$(SQL_PASSWORD)

k3s-install: 
	echo "Creating k3s cluster"
	source get_env.sh && ssh -o StrictHostKeyChecking=no ec2-user@$${IP0} "curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=$(K3S_CHANNEL) INSTALL_K3S_EXEC='server' K3S_DATASTORE_ENDPOINT='$${RDS_PRE}$(SQL_PASSWORD)$${RDS_POST}' K3S_TOKEN=$(K3S_TOKEN) K3S_KUBECONFIG_MODE=644 K3S_DEBUG=1 sh -"
	source get_env.sh && ssh -o StrictHostKeyChecking=no ec2-user@$${IP0} "curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=$(K3S_CHANNEL) INSTALL_K3S_EXEC='server' K3S_DATASTORE_ENDPOINT='$${RDS_PRE}$(SQL_PASSWORD)$${RDS_POST}' K3S_TOKEN=$(K3S_TOKEN) K3S_KUBECONFIG_MODE=644 sh -"
	source get_env.sh && scp -o StrictHostKeyChecking=no ec2-user@$${IP0}:/etc/rancher/k3s/k3s.yaml kubeconfig
	source get_env.sh && sed -i '' "s/127.0.0.1/$${URL}/g" kubeconfig


rancher: 
	echo "Installing cert-manager and Rancher"
	helm repo update
	helm upgrade --install \
		  cert-manager jetstack/cert-manager \
		  --namespace cert-manager \
		  --version v1.0.3 --create-namespace --set installCRDs=true
	kubectl rollout status deployment -n cert-manager cert-manager
	kubectl rollout status deployment -n cert-manager cert-manager-webhook
	helm upgrade --install rancher rancher-stable/rancher \
	  --namespace cattle-system \
	  --version ${RANCHER_VERSION} \
	  --set hostname=rancher-demo.mak3r.design \
	  --set bootstrapPassword=${ADMIN_SECRET} \
	  --create-namespace 
	kubectl rollout status deployment -n cattle-system rancher
	kubectl -n cattle-system wait --for=condition=ready certificate/tls-rancher-ingress
	echo
	echo
	echo https://rancher-demo.mak3r.design/dashboard/?setup=${ADMIN_SECRET}
