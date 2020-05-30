#!/bin/bash

#set -x

get_manifest_sha(){
    local sha
    docker_repo=$1  #alpine or vmnet/alpine
    manifest_tag=$2
    docker_image=$docker_repo:$manifest_tag
    arch=$3
    variant=$4
    export DOCKER_CLI_EXPERIMENTAL=enabled

#    docker pull -q  ${docker_image} &>/dev/null
    docker manifest inspect ${docker_image} > "$2".txt

    sha=""
    i=0
    while [ "$sha" == "" ] && read -r line
    do
        arch=$(jq .manifests[$i].platform.architecture "$2".txt |sed -e 's/^"//' -e 's/"$//')
        if [ "$arch" = "$3" ] && [ "$arch" !=  "arm" ]; then
            sha=$(jq .manifests[$i].digest "$2".txt  |sed -e 's/^"//' -e 's/"$//')
            echo ${sha}
        elif [ "$arch" = "$3" ]; then
            variant=$(jq .manifests[$i].platform.variant "$2".txt |sed -e 's/^"//' -e 's/"$//')
            if [ "$variant" == "$4" ]; then
                sha=$(jq .manifests[$i].digest "$2".txt  |sed -e 's/^"//' -e 's/"$//')
                echo ${sha}
            fi
        fi
        i=$i+1
    done < "$2".txt
}

get_tag_sha(){
    #docker_image=$1
    local repo=$1
    local tag=$2
    docker pull "$repo:$tag" &>/dev/null
    #sha=$(docker inspect --format='{{index .RepoDigests 0}}' balenalib/raspberry-pi-alpine:run | cut -d @ -f 2)
    sha=$(docker inspect --format='{{index .RepoDigests 0}}' "$repo:$tag" 2>/dev/null | cut -d @ -f 2)
    #docker inspect --format='{{index .RepoDigests 0}}' "$repo:$tag" 2>/dev/null | cut -d @ -f 2
    echo $sha
}


compare_sha () {
    [ "$1" = "$2" ]
}

manifest_sha () {
    if ! compare_sha "$1" "$2" || ! compare_sha "$3" "$4" ; then
        create_manifest
    else
        echo "no need to create new manifest"
    fi
}

create_manifest(){
    echo "will create manifest"
    #offical_image=$1
    #my_repo=$2
    #arch=$3
    #my_tag=$4
    ##my_new_image=$my_repo:$my_new_tag
    ##echo $my_new_image
    #timetag="$(date +%Y%m%d%H%M)"
    #docker -q pull $1
    #docker tag $1 "$2":"$3"-$my_tag-$timetag
    #docker push vmnet8/alpine-tags:$arch-$my_tag-$timetag
    #echo "create new manifest"
    #echo ""
    #docker manifest create vmnet8/alpine:$manifest_tag-$timetag
    #docker manifest push vmnet8/alpine:$manifest_tag-$timetag
}
push_manifest(){

    echo "push manifest"
}

ALPINE_REPO='alpine'
MY_ALPINE_REPO='vmnet8/alpine'
MY_RPI_REPO='vmnet8/alpine-tags'
BELENA_REPO='balenalib/raspberry-pi-alpine'

compare_alpine() {
    local tag=$1
    local arch=$2
    alpine_sha=$(get_manifest_sha $ALPINE_REPO $tag $arch)
 #   echo $alpine_sha
    my_alpine_sha=$(get_manifest_sha $MY_ALPINE_REPO $tag $arch)
 #   echo $my_alpine_sha
    if [ "$alpine_sha" != "$my_alpine_sha" ]; then
        create_manifest
        push_manifest
    fi
    #if [ "$arch" = arm ]; then
    #    balena_rpi_sha=$(get_tag_sha $BELENA_REPO $tag)
    #    echo $balena_rpi_sha
    #    my_rpi_sha=$(get_tag_sha $MY_RPI_REPO $tag)
    #    echo $my_rpi_sha
    #    if [ "$belena_rpi_sha" != "$my_rpi_sha" ]; then
    #        create_manifest
    #    fi
    #fi
}

compare_balena() {
    local balena_tag=$1
    local my_tag=$2
    balena_rpi_sha=$(get_tag_sha $BELENA_REPO $1)
 #   echo $balena_rpi_sha
    my_rpi_sha=$(get_tag_sha $MY_RPI_REPO $2)
  #  echo $my_rpi_sha
    if [ "$belena_rpi_sha" != "$my_rpi_sha" ]; then
        create_manifest
        push_manifest
    fi
}
#compare_sha $1 $2
#compare_alpine $@
#compare_balena $@
#get_manifest_sha "vmnet8/alpine:$manifest_tag" "$arch"
#get_manifest_sha $@
#get_vmnet_sha $1 $2
#get_tag_sha $1 $2
#create_manifest
#manifest_sha $1 $2 $3 $4
