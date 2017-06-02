# Create and run a docker container that is able to run snap packages

This script allows you to create docker containers that are able to run and
build snap packages.

**NOTE**: This will create a container with security options disabled, this is an unsupported setup, if you have multiple snap packages inside the container they will be able to break out of the confinement and see each others data Use this setup to build or test single snap packages but do not rely on security inside the container.

```
usage: build.sh [options]

  -c|--containername <name> (default: snappy)
  -i|--imagename <name> (default: snapd)
```
