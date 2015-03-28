#!/bin/bash
set -e

IMAGE_NAME="html5-boilerplate"

# Echo the command prefixed with '++' than run it
echo_and_run () {
    echo ++ "$@"
    eval "$@" 
}

# Check if the image exists in docker, otherwise run it
if ! docker images | grep -q "$IMAGE_NAME"
then
    echo_and_run \
    docker build -t "$IMAGE_NAME" github.com/IxDay/docker-html5-boilerplate
fi

# Initialize the directory if empty
[ "$(ls -A .)" ] || echo_and_run docker run -v $(pwd):/mnt "$IMAGE_NAME" init

# Checks if a container with the same name is not already running
CONTAINER=$(docker ps | awk '$2 ~ /'"$IMAGE_NAME"'/ { print $1 }')

if [ ! -z $CONTAINER ]
then
    echo "The container is already running, its id is $CONTAINER"
    while true
    do
        echo "kill it? [y/N]"
        read KILL
        [ -z $KILL ] && exit
        [ "$KILL" = "y" ] && break
    done
    echo_and_run docker kill $CONTAINER
fi

# Run the container and serve pwd directly with livereload
echo_and_run docker run -v $(pwd):/mnt html5-boilerplate

