.PHONY: init plan apply destroy validate

# A separate kubeconfig keeps the user's default kubectl context untouched.
KUBECONFIG_FILE := $(CURDIR)/kubeconfig

init:
	terraform init

plan:
	terraform plan -out=tfplan

apply:
	terraform apply tfplan
	aws eks update-kubeconfig --region "$$(terraform output -raw region)" --name "$$(terraform output -raw cluster_name)" --kubeconfig $(KUBECONFIG_FILE)

# The demo app goes first: its PodDisruptionBudget would otherwise hold the node drain.
destroy:
	-KUBECONFIG=$(KUBECONFIG_FILE) kubectl delete -f k8s/demo-app --ignore-not-found --wait
	terraform destroy

validate:
	terraform fmt -check -recursive
	terraform validate
	tflint --init
	tflint
	helm lint k8s/karpenter --set clusterName=validate,nodeRoleName=validate
