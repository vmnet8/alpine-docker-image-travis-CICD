#!/bin/bash
source sha_function.sh
MY_ALPINE_REPO='vmnet8/alpine'
push_manifest (){
    create_manifest $@
    local my_alpine_tag=$1
    echo "push manifest"
    docker manifest push $MY_ALPINE_REPO:$my_alpine_tag
}
