#!/bin/bash
###############################################################################
# Build MTK2020 SELinux inside a Docker
# Usage: docker-build.sh [--version=<version>]
###############################################################################
mypath=$(dirname $0)

docker_img=selinux-img
docker_ctnr=selinux-ctnr

die()
{
  exit_code=$1
  shift
  echo $*
  exit $exit_code
}

# handle version info
test -n "$1" && ver=$1

## make sure Docker container is in usable state
#ctnr_check=$(docker inspect -f '{{.State.Status}}' $docker_ctnr 2>/dev/null)
#retval=$?
#case "$retval$ctnr_check" in
#  "0running") docker container stop $docker_ctnr 
#              docker container rm   $docker_ctnr
#              ;;
#  "0exited")  docker container rm   $docker_ctnr
#              ;;
#esac

cd Docker

# create Docker image
docker build --tag $docker_img -f Dockerfile . \
    || die 2 "docker build failed"

# run commands in Docker container
cmds="\
./build/gen-policy.sh
"

docker run \
  -u $(id -u):$(id -g) \
  -v $(pwd)/..:/usr/src/mtk-selinux \
  $VERSION_INFO \
  --name $docker_ctnr \
  --rm \
  $docker_img \
  /bin/bash -c "$cmds"
