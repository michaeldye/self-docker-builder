# Self Docker builder

## Build container image

### Preconditions

 * Install and set up Docker CE. See https://docs.docker.com/get-started/.

 * Deep clone https://github.com/watson-intu/self.git to a convenient and capacious filesystem location; you will later set the make variable `self_DIR` during the build process so keep the path handy.

### Steps

 * Create a `self` image with an invocation like this:

        make self_DIR=$HOME/projects/self all

If you do not already have them available, this will build a `self-docker-builder-i` build image, run that image as a `self-docker-builder` container, compile the `self` source, extract the build artifacts, and create a slimmer runtime container with `self` inside it. If you want to perform just some of the above steps, consult the `Makefile` for targets you might run.

Note that if you invoke a make target that builds a Docker container without specifying `DOCKERB_OPTS` or `DOCKERE_OPTS`, Docker will ignore all cached build layers (for the build container and execution container respectively). To override this and get some work saving benefit, invoke make with the option `DOCKERB_OPTS=""`.

 * Build the `self` project with a command like:

        docker exec -it self-docker-builder /self/scripts/build.sh linux

### Other options

To get more build output from make, set the `VERBOSE=y` build option.

### Cleanup

When you're finished with the build container and image, you can execute `make self_DIR=$HOME/projects/self distclean` in this project directory and clean up docker and other artifacts from the build process. Note that if you used Docker efficiencies when building, there may be extra, untagged Docker images on your system. Consult the Docker documentation for information on deleting such images.

### Known problems

 * The build process for non-x86 boxes fails
 * Documentation of all build features is lacking
