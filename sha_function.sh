#!/bin/bash
# get_manifest_sha function is going to get alpine docker image's sha of all kinds of archtecture: amd65 armv6 armv7 armv8 386 etc
get_manifest_sha(){
    local sha
    docker_repo=$1  #alpine or vmnet/alpine
    manifest_tag=$2
    docker_image=$docker_repo:$manifest_tag
    arch=$3         # amd64 or arm or 386
    variant=$4
    export DOCKER_CLI_EXPERIMENTAL=enabled

    docker pull -q  ${docker_image} &>/dev/null
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
# get_my_manifest_sha is going to get vmnet8/alpine docker image's sha, only two archectures: amd64 and arm
get_my_manifest_sha (){
    local repo=$1
    local arch=$2
    docker pull -q $1 &>/dev/null
    docker manifest inspect $1 > "$2".txt
    sha=""
    i=0
    while [ "$sha" == "" ] && read -r line
    do
        archecture=$(jq .manifests[$i].platform.architecture "$2".txt |sed -e 's/^"//' -e 's/"$//')
        if [ "$archecture" = "$2" ];then
            sha=$(jq .manifests[$i].digest "$2".txt  |sed -e 's/^"//' -e 's/"$//')
            echo ${sha}
        fi
        i=$i+1
    done < "$2".txt

}
# get_tag_sha function is going to get balenalib:raspberry-pi-alpine image's sha.
get_tag_sha(){
    local repo=$1    # not manifest docker image
    local tag=$2
    docker pull "$repo:$tag" &>/dev/null
    sha=$(docker inspect --format='{{index .RepoDigests 0}}' "$repo:$tag" 2>/dev/null | cut -d @ -f 2)
    echo $sha
}

compare_sha () {
    if [ "$1" != "$2" ] || [ "$3" != "$4" ]; then
        echo "true"
    else
        echo "false"
    fi
}

create_manifests(){
    local repo=$1
    local tag=$2
    local x86=$3
    local rpi=$4
    docker manifest create $repo:$tag $x86 $rpi
    docker manifest create $repo:latest $x86 $rpi
    docker manifest annotate $repo:latest $rpi --arch arm
    docker manifest annotate $repo:$tag $rpi --arch arm
}
