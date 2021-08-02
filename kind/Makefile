# CLI DEPENDENCIES
KIND_CLI = $(shell which kind 2> /dev/null)

# GKE CLUSTER INFO
CLUSTER_NAME			?= "ldelossa-dev"
CLUSTER_CONFIG          ?= "./kind/config.yaml"

.PHONY: kind-help kind-cluster-up kind-cluster-down 

define KIND_HEL 
King Targets:
	kind-cluster-up           - Deploy a kind cluster and local registry on your local machine
	kind-cluster-down         - Destroy a kind cluster and local registry on your local machine
Kind Target Variables:
	CLUSTER_NAME              - Kind cluster name 
	CLUSTER_CONFIG            - Path to kind yaml configuration 

Using The Registry:
The registry can be used like this.

First we'll pull an image docker pull gcr.io/google-samples/hello-app:1.0
Then we'll tag the image to use the local registry docker tag gcr.io/google-samples/hello-app:1.0 localhost:5000/hello-app:1.0
Then we'll push it to the registry docker push localhost:5000/hello-app:1.0
And now we can use the image kubectl create deployment hello-server --image=localhost:5000/hello-app:1.0
endef

export KIND_HELP
kind-help:
	@echo "$$KIND_HELP"

kind-cluster-up:
ifeq (, $(KIND_CLI))
	@echo "kind cli not available"	
else
	@echo "creating local registry...."
	@./kind/local_registry.sh
	echo "creating cluster"
	$(KIND_CLI) create cluster  --name $(CLUSTER_NAME) --config $(CLUSTER_CONFIG) 
	@docker network connect "kind" 'kind-registry' || true
	@kubectl apply -f ./kind/local_registry_configmap.yaml
endif

kind-cluster-down:
ifeq (, $(KIND_CLI))
	@echo "kind cli not available"	
else
	$(KIND_CLI) delete cluster --name $(CLUSTER_NAME)
	@docker kill "kind-registry"
endif

frr-up:
	docker run -d --privileged --network kind --rm --name frr --volume $(pwd)/dev-env/bgp/frr-volume:/etc/frr frrouting/frr:latest
