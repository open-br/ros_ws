#!/bin/env bash

usage() {
    printf "Usage: $0 [ROS_DISTRO] t]\n"
    printf "Build test and devel images for the provided ROS_DISTRO\n\n"
    printf "Options:\n"
    printf "  -h|--help\t\t Shows this help message\n"

    exit 0
}

parse_args() {
  local SHORT=h,d:
  local LONG=distro:

  local OPTS=$(getopt -o $SHORT -l $LONG --name "$0" -- "$@")

  if [ $? != 0 ] ; then echo "Failed to parse options...exiting." >&2 ; exit 1 ; fi

  eval set -- "$OPTS"

  . settings.sh  # set initial values

  while true ; do
    case "$1" in
      -d | --distro )
        ROS_DISTRO="$2"
        shift 2
        ;;
      --test )
        BUILD_TEST="$2"
        shift 2
        ;;
      -- )
        shift
        break
        ;;
      -h | *)
        usage
        shift
        ;;
    esac
  done

}

validate_ros_distro() {
  local distro=$1
  if [[ ! $VALID_ROS_DISTROS =~ (^|[[:space:]])"${distro}"($|[[:space:]]) ]]; then
    echo "Not supported ROS_DISTRO '${distro}'" &2
    usage
    exit 1
  fi
}

build_image() {
  validate_ros_distro ${ROS_DISTRO}

  if [[ "$BUILD_TEST" == "true" ]]; then
    docker build --build-arg ROS_DISTRO=$ROS_DISTRO -t orise-robotics/ros-$ROS_DISTRO:test -f Dockerfile.test .
  fi

  docker build --build-arg ROS_DISTRO=$ROS_DISTRO -t orise-robotics/ros-$ROS_DISTRO:devel .
}

main() {
    parse_args "$@"
    build_image
}

main "$@"
