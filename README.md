# shim-build

Build [shim](https://github.com/rhboot/shim) in a Docker container.

## Makefile targets

Build shim in a Docker container:

    make build
    
Build with the cache turned off to get the full build log:
    
    make build-no-cache
    
Copy the shim builds from the container to the host:
    
    make copy

View details of the public certificate:

    make cert-info
