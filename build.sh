#! /bin/sh
#
# make sure to have the docker.io deb installed before running this script!
#

set -e

CONTNAME=snappy
IMGNAME=snapd
RELEASE=17.04

SUDO=""
if ! $(id -Gn|grep -q docker); then
	SUDO="sudo"
fi

usage() {
	echo "usage: $(basename $0) [options]"
	echo
	echo "  -c|--containername <name> (default: snappy)"
	echo "  -i|--imagename <name> (default: snapd)"
    exit 0
}

print_info() {
	echo
    echo "use: $SUDO docker exec -it $CONTNAME <command> ... to run a command inside this container"
    echo
    echo "to remove the container use: $SUDO docker rm -f $CONTNAME"
    echo "to remove the related image use: $SUDO docker rmi $IMGNAME"
}

while [ $# -gt 0 ]; do
       case "$1" in
               -c|--containername)
                       [ -n "$2" ] && CONTNAME=$2 shift || usage
                       ;;
               -i|--imagename)
                       [ -n "$2" ] && IMGNAME=$2 shift || usage
                       ;;
               -h|--help)
                       usage
                       ;;
               *)
                       ERROR="$1 is unknown" exit 1
                       ;;
       esac
       shift
done

if [ -n "$($SUDO docker ps -f name=$CONTNAME -q)" ]; then
	echo "Container $CONTNAME already running!"
	print_info
	exit 0
fi

if [ -z "$($SUDO docker images|grep $IMGNAME)" ]; then
	BUILDDIR=$(mktemp -d)
    cat << EOF > $BUILDDIR/Dockerfile
FROM ubuntu:$RELEASE
ENV container docker
RUN apt-get update
RUN apt-get install -y fuse snapd snap-confine squashfuse
RUN rm -f /sbin/udevadm; ln -s /bin/true /sbin/udevadm
RUN mkdir -p /lib/modules
RUN systemctl enable snapd
VOLUME [ “/sys/fs/cgroup” ]
STOPSIGNAL SIGRTMIN+3
CMD [ "/sbin/init" ]
EOF
    $SUDO docker build -t $IMGNAME $BUILDDIR
	rm -rf $BUILDDIR
fi

# start the detached container
$SUDO docker run \
	--name=$CONTNAME \
	-ti \
	--tmpfs /run \
	--tmpfs /run/lock \
	--tmpfs /tmp \
	--cap-add SYS_ADMIN \
	--device=/dev/fuse \
	--security-opt apparmor:unconfined \
	--security-opt seccomp:unconfined \
	-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	-d $IMGNAME

# wait for snapd to start
TIMEOUT=20
SLEEP=3
echo -n "Waiting $(($TIMEOUT*3)) seconds for snapd startup"
while [ -z "$($SUDO docker exec $CONTNAME pgrep snapd)" ]; do
	echo -n "."
	sleep $SLEEP
	if [ "$TIMEOUT" -le "0" ]; then
		echo " Timed out!"
		exit 0
	fi
	TIMEOUT=$(($TIMEOUT-1))
done

$SUDO docker exec $CONTNAME snap install core --edge
echo "container $CONTNAME started ..."

print_info
