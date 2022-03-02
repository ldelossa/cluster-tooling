# CLI DEPENDENCIES
KIND_CLI 	= $(shell which kind 2> /dev/null)
KUBECTL_CLI = $(shell which kubectl 2> /dev/null)
DOCKER_CLI  = $(shell which docker 2> /dev/null)

define dependency_check
	$(if $(KIND_CLI),,$(error kind cli is required to run this target))
	$(if $(KUBECTL_CLI),,$(error kubectl cli is required to run this target))
	$(if $(DOCKER_CLI),,$(error docker cli is required to run this target))
endef

# GKE CLUSTER INFO
CLUSTER_NAME			?= "ldelossa-dev"
CLUSTER_CONFIG          ?= "./kind/cluster_config.yaml"

.PHONY: kind-help kind-cluster-up kind-cluster-down frr-up frr-down cilium-bgp-install cilium-bgp-uninstall

define KIND_HELP
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
	$(depdendency_check)
	@echo "creating local registry...."
	@./kind/local_registry.sh
	echo "creating cluster"
	$(KIND_CLI) create cluster  --name $(CLUSTER_NAME) --config $(CLUSTER_CONFIG) 
	@docker network connect "kind" 'kind-registry' || true
	@kubectl apply -f ./kind/local_registry_configmap.yaml

kind-cluster-down:
	$(depdendency_check)
	@echo "kind cli not available"	
	$(KIND_CLI) delete cluster --name $(CLUSTER_NAME)
	@-docker kill "kind-registry"

cilium-bgp-install:
	$(depdendency_check)
	kubectl apply -f ./kind/bgp/bgp_configmap.yaml
	cilium install \
	--agent-image "quay.io/cilium/cilium-ci" \
	--version "latest" \
	--operator-image "quay.io/cilium/operator-generic-ci" \
	--config="bgp-announce-lb-ip=true" \
	--config="bgp-announce-pod-cidr=true" \
	--config="debug=true" \
	--ipam kubernetes

cilium-bgp-uninstall:
	cilium uninstall

frr-up:
	$(depdendency_check)
	docker run -d --privileged --network kind --name frr \
		--ip6="fc00:f853:ccd:e793::50" \
		--volume $(shell pwd)/kind/bgp/frr:/etc/frr:z \
		frrouting/frr:v8.0.1

frr-down:
	$(depdendency_check)
	docker kill frr
	docker rm frr

frr-shell:
	docker exec -it frr vtysh

bird-up:
	$(depdendency_check)
	docker run -d --privileged --network kind --name bird \
		--ip="172.18.0.50" \
		--volume $(shell pwd)/kind/bgp/bird:/etc/bird:z \
		pierky/bird	

bird-up-logs:
	$(depdendency_check)
	make bird-down
	docker run -d --privileged --network kind --name bird \
		--ip="172.18.0.50" \
		--volume $(shell pwd)/kind/bgp/bird:/etc/bird:z \
		pierky/bird	
	docker logs -f bird

bird-down:
	$(depdendency_check)
	-docker kill bird
	-docker rm bird

