# CLI DEPENDENCIES
GCLOUD_CLI = $(shell which gcloud 2> /dev/null)

# GKE CLUSTER INFO
CLUSTER_VER				?= "" # will use gke default if not specified.
CLUSTER_NAME			?= "ldelossa-dev"
CLUSTER_ZONE			?= "us-east4-a"
CLUSTER_NETWORK			?= "ldelossa-net"
CLUSTER_SUBNET			?= "ldelossa-net"
CLUSTER_PROJECT			?= "cilium-dev"
CLUSTER_NODES   		?= "2"
CLUSTER_MACHINE_TYPE 	?= "c2-standard-4"

# GKE specific HELM directive
NATIVE_CIDR ?= $(shell $(GCLOUD_CLI) container clusters describe $(CLUSTER_NAME) --zone $(CLUSTER_ZONE) --format "value(clusterIpv4Cidr)" 2> /dev/null)

.PHONY: gke-help gke-cluster-up gke-cluster-down gke-cilium-install-helm gke-cilium-upgrade-helm

define GKE_HELP
GKE Targets:
	gke-cluster-up            - starts a GKE cluster
	gke-cluster-down          - tears down the created GKE cluster
	gke-cilium-upgrade-helm   - install or upgrade a cilium deployment via helm

GKE Target Variables:
	CLUSTER_VER               - kubernetes cluster version
	CLUSTER_NAME              - kubernetes cluster name 
	CLUSTER_ZONE              - GCP zone to deploy k8s cluster in
	CLUSTER_NETWORK           - GCP network to deploy k8s cluster in
	CLUSTER_SUBNET            - GCP subnet within CLUSTER_NETWORK to deploy k8s server in
	CLUSTER_PROJECT           - GCP project to deploy k8s cluster in.
	CLUSTER_NODES			  - Number of k8s nodes to deploy.
	CLUSTER_MACHINE_TYPE      - GCP machine type of nodes.
	HELM_VALUES				  - Path to helm values to use instead of defaults. (nativeRoutingCIDR is still dynamically set)
endef

export GKE_HELP
gke-help:
	@echo "$$GKE_HELP"

# create a gke cluster
gke-cluster-up:
ifeq (, $(GCLOUD_CLI))
	@echo "gcloud cli not available"	
else
	$(GCLOUD_CLI) container clusters create "ldelossa-dev" \
		--cluster-version $(CLUSTER_VER) \
		--node-taints node.cilium.io/agent-not-ready=true:NoSchedule \
		--zone $(CLUSTER_ZONE) \
		--network $(CLUSTER_NETWORK) \
		--subnetwork $(CLUSTER_SUBNET) \
		--num-nodes $(CLUSTER_NODES) \
		--machine-type $(CLUSTER_MACHINE_TYPE)
	@$(GCLOUD_CLI) container clusters get-credentials $(CLUSTER_NAME) --zone $(CLUSTER_ZONE) --project $(CLUSTER_PROJECT)
endif

# teardown a gke cluster
gke-cluster-down:
ifeq (, $(GCLOUD_CLI))
	@echo "gcloud cli not available"	
else
	@$(GCLOUD_CLI) container clusters delete $(CLUSTER_NAME) --zone $(CLUSTER_ZONE)
endif

# install or upgrade cilium oss via helm
gke-cilium-upgrade-helm:
ifeq (, $(HELM_CLI))
	@echo "helm cli not available"	
else ifeq (, $(GCLOUD_CLI))
	@echo "helm cli not available"	
else
  ifeq (,$(NATIVE_CIDR))
	@echo "could not determine native cidr of cluster"
  else ifneq (, $(HELM_VALUES))
	$(HELM_CLI) upgrade cilium cilium/cilium --version $(CILIUM_VER) \
		--values $(HELM_VALUES) \
		--namespace kube-system \
		--set nativeRoutingCIDR=$(NATIVE_CIDR) \
		--install 
  else
	$(HELM_CLI) upgrade cilium cilium/cilium --version $(CILIUM_VER) \
		--namespace kube-system \
		--set nodeinit.enabled=true \
		--set nodeinit.reconfigureKubelet=true \
		--set nodeinit.removeCbrBridge=true \
		--set cni.binPath=/home/kubernetes/bin \
		--set gke.enabled=true \
		--set ipam.mode=kubernetes \
		--set nativeRoutingCIDR=$(NATIVE_CIDR) \
		--install 
  endif
endif
