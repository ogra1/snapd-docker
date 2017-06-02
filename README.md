# Create and run a docker container that is able to run snap packages

This script allows you to create docker containers that are able to run and
build snap packages.

**NOTE**: This will create a container with security options disabled, this is an unsupported setup, if you have multiple snap packages inside the container they will be able to break out of the confinement and see each others data Use this setup to build or test single snap packages but do not rely on security inside the container.

```
usage: build.sh [options]

  -c|--containername <name> (default: snappy)
  -i|--imagename <name> (default: snapd)
```

## Examples

Creating a container with defaults (image: snapd, container name: snappy):

```
$ sudo apt install docker.io
$ ./build.sh
```

Installing a snap package:

This will install the htop snap and will show the running processes inside the container after connecting the right snap interfaces.

```
$ sudo docker exec -it snappy snap install htop
htop 2.0.2 from 'maxiberta' installed
$ sudo docker exec -it snappy snap connect htop:process-control
$ sudo docker exec -it snappy snap connect htop:system-observe
$ sudo docker exec -it snappy /snap/bin/htop
```

Building snaps using the snapcraft snap package (using the default "snappy" name):

```
$ sudo docker exec -it snappy sh -c 'apt -y install git sudo'
$ sudo docker exec -it snappy snap install snapcraft --edge --classic
$ sudo docker exec -it snappy sh -c 'git clone https://github.com/ogra1/beaglebone-gadget'
$ sudo docker exec -it snappy sh -c 'cd beaglebone-gadget; cp crossbuild-snapcraft.yaml snapcraft.yaml; LC_ALL=C.UTF-8 TMPDIR=. /snap/bin/snapcraft'
...
./scripts/config_whitelist.txt . 1>&2
Staging uboot
Priming uboot
Snapping 'bbb' |
Snapped bbb_16-0.1_armhf.snap
$
```
