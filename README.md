# Self Docker builder

## Build container image

### Preconditions

 * Install and set up Docker CE. See https://docs.docker.com/get-started/.

 * Deep clone https://github.com/watson-intu/self.git to a convenient and capacious filesystem location; you will later set the make variable `self_DIR` during the build process so keep the path handy.

### Steps

 * Create a `self-docker-builder` image and container instance with an invocation like this:

        make self_DIR=$HOME/projects/self all

(Note that if you invoke make without specifying `DOCKERB_OPTS`, Docker will ignore all cached build layers. To override this and get some work saving benefit, invoke make with the option `DOCKERB_OPTS=`)

 * Build the `self` project with a command like:

        docker exec -it self-docker-builder /self/scripts/build.sh linux

### Cleanup

When you're finished with the build container and image, you can execute `make distclean` in this project directory and clean up docker and other artifacts from the build process. Note that if you used Docker efficiencies when building, there may be extra, untagged Docker images on your system. Consult the Docker documentation for information on deleting such images.
