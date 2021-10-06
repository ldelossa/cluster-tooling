# CLI DEPENDENCIES
EKSCTL_CLI = $(shell which eksctl 2> /dev/null)

.PHONY: eks-help eks-cluster-up eks-cluster-down eks-cilium-install-helm eks-cilium-upgrade-helm

define EKS_HELP
EKS Targets:
	eks-cluster-up            - starts a EKS cluster
	eks-cluster-down          - tears down the created EKS cluster
	eks-cilium-upgrade-helm   - install or upgrade a cilium deployment via helm

EKS Target Variables:
	All EKS related variables are maintained in ./eks/eks-config.yaml
endef

export EKS_HELP
eks-help:
	@echo "$$EKS_HELP"

eks-cluster-up:
	eksctl --profile cilium-dev create cluster -f ./eks/eks-config.yaml

eks-cluster-down:
	eksctl --profile cilium-dev delete cluster -f ./eks/eks-config.yaml
