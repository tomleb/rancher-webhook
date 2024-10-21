TARGETS := $(shell ls scripts)

REGISTRY ?= webhook
CLUSTER ?= webhook

create-cluster:
	@k3d registry create $(REGISTRY)
	@k3d cluster create --registry-use $(REGISTRY) $(CLUSTER)

delete-cluster:
	@k3d cluster delete $(CLUSTER)
	@k3d registry delete $(REGISTRY)

.dapper:
	@echo Downloading dapper
	@curl -sL https://releases.rancher.com/dapper/latest/dapper-$$(uname -s)-$$(uname -m) > .dapper.tmp
	@@chmod +x .dapper.tmp
	@./.dapper.tmp -v
	@mv .dapper.tmp .dapper

$(TARGETS): .dapper
	./.dapper $@

clean:
	rm -rf build bin dist

.DEFAULT_GOAL := default

.PHONY: $(TARGETS)
