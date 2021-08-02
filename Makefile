# CLI DEPEDENCIES
HELM_CLI   = $(shell which helm   2> /dev/null)
CILIUM_CLI = $(shell which cilium 2> /dev/null)

# CILIUM CLUSTER INFO
CILIUM_VER ?= "1.10.3"

define HELP
This makefile will create k8s clusters in various cloud
providers and deploy cilium to these clusters.

To learn more about deploying to a particular cloud
see the cloud-provider-specific help targets.

Global targets are commands which can be applied to
a k8s cluster regardless of which cloud it was deployed on
and utilize the current context of the kubectl tool.

Cloud Provider Help Targets:
	gke-help                   - display GKE specific targets and variables
	kind-help                  - display Kind specific targets and variables

Global Targets:
	hubble-install-helm        - deploy hubble via helm to the currently configured k8s context. (helm install of cilium is required.) 

Global Variables:
	CILIUM_VER                 - the version of cilium to deploy used by both global and cloud provider targets
endef

.PHONY: help hubble-install-helm

export HELP
help:
	@echo "$$HELP"

# install hubble to the currently configured kubectl
# context.
hubble-install-helm:
ifeq (, $(HELM_CLI))
	@echo "helm cli not available"	
else
	$(HELM_CLI) upgrade cilium cilium/cilium --version $(CILIUM_VER) \
   --namespace kube-system \
   --reuse-values \
   --set hubble.relay.enabled=true \
   --set hubble.ui.enabled=true
endif

# include gke specific targets
include ./gke/Makefile
# include kind specific targets
include ./kind/Makefile

