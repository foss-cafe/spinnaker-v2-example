CHART_NAME=$(shell cat chart/spin-helm-demo/Chart.yaml | yq -r .name)
CHART_VERSION=$(shell cat chart/spin-helm-demo/Chart.yaml | yq -r .version)

APP_VERSION ?= $(shell cat chart/spin-helm-demo/Chart.yaml | yq -r .appVersion)


CHART_BUCKET ?= helm-artifacts-srijan-test
DOCKER_REPO ?= rajivnix/helm-spin-demo
SPINNAKER_API ?= http://localhost:8084

docker:
	docker build -t $(DOCKER_REPO):$(APP_VERSION) .
	#docker tag $(DOCKER_REPO):$(APP_VERSION) $(DOCKER_REPO):latest

dockerpush: docker
	docker push $(DOCKER_REPO):$(APP_VERSION)
	#docker push $(DOCKER_REPO):latest

compile:
	helm package chart/spin-helm-demo

upload:
	aws s3 cp $(CHART_NAME)-$(CHART_VERSION).tgz s3://$(CHART_BUCKET)/packages/ 
	aws s3 cp values/dev.yaml s3://$(CHART_BUCKET)/packagevalues/$(CHART_NAME)/dev.yaml
	aws s3 cp values/prod.yaml s3://$(CHART_BUCKET)/packagevalues/$(CHART_NAME)/prod.yaml

triggerdocker:
	curl -L -vvv -X POST \
		-k \
		-H"Content-Type: application/json" $(SPINNAKER_API)/webhooks/webhook/spinhelmdemo \
		-d '{"artifacts": [{"type": "docker/image", "name": "$(DOCKER_REPO)", "reference": "$(DOCKER_REPO):$(APP_VERSION)", "kind": "docker"}]}'
	# curl -vvvv -L -k -X POST $(SPINNAKER_API)/webhooks/webhook/spinhelmdemo -H 'Content-Type: application/json' \
	# 	-d '{"artifacts": [{
    #         "type": "docker/image",
    #         "name": "$(DOCKER_REPO)",
    #         "kind": "docker",
    #         "reference": "$(DOCKER_REPO):$(APP_VERSION)"
    #     	}]
	# 	}'
# triggerchart:
# 	curl -L -vvv -X POST \
# 		-k \
# 		-H"Content-Type: application/json" $(SPINNAKER_API)/webhooks/webhook/spinhelmdemo \
# 		-d '{"artifacts": [{"type": "s3/object", "name": "s3://$(CHART_BUCKET)/packages/spin-helm-demo-0.1.0.tgz", "reference": "s3://$(CHART_BUCKET)/packages/spin-helm-demo-$(CHART_VERSION).tgz", "kind": "s3"}]}'
