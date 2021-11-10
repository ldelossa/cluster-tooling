# CLI DEPENDENCIES
EKSCTL_CLI 			= $(shell which eksctl 2> /dev/null)
EKS_PROFILE			?= "cilium-dev"

define dependency_check
	$(if $(EKSCTL_CLI),,$(error eksctl cli is required to run this target))
endef

.PHONY: eks-help eks-cluster-up eks-cluster-down eks-cilium-install-helm eks-cilium-upgrade-helm

define EKS_HELP
EKS Targets:
	eks-cluster-up            - starts a EKS cluster
	eks-cluster-down          - tears down the created EKS cluster

EKS Target Variables:
	EKS_PROFILE	              - the eksctl profile to use when deploying the cluster (cilium-dev)

	All other EKS related variables are maintained in ./eks/eks-config.yaml
	Edit this file for change EKS cluster configuration.
endef

export EKS_HELP
eks-help:
	@echo "$$EKS_HELP"

eks-cluster-up:
	$(dependency_check)
	eksctl --profile $(EKS_PROFILE) create cluster -f ./eks/eks-config.yaml

eks-cluster-down:
	$(dependency_check)
	eksctl --profile $(EKS_PROFILE) delete cluster -f ./eks/eks-config.yaml
