TAG=shim-build

build:
	sudo docker build -t ${TAG} .

# Build without cache to make grabbing the full build log easier
build-no-cache:
	sudo docker build --no-cache -t ${TAG} .

# Run the container to copy the two shim builds to the host
copy:
	sudo docker run -v ${PWD}:/host:z ${TAG} cp -r /build/install /host

.PHONY: build build-no-cache copy