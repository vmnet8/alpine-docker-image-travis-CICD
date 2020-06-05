#!/bin/bash
source sha_function.sh
set -x
export DOCKER_CLI_EXPERIMENTAL=enabled
#MY_ALPINE_REPO='vmnet8/alpine'
push_manifest (){
    #create_manifest "latest" "latest" "3.12.1"
    #local my_alpine_tag=$1
    echo "created a manifest"
    echo "going to pushing manifest"
    #docker manifest push $(create_manifest "latest" "latest" "3.12.1")
}

push_manifest
