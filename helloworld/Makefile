VERSIONS = 1.0 1.0.1 2.0 2.0.1a 2.0.1b
IMAGE=jovandeginste/hello

images: $(VERSIONS)

$(VERSIONS):
	docker build --build-arg VERSION=$@ -t $(IMAGE):$@ .
	docker push $(IMAGE):$@
