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
    docker_image=$1
    docker pull "$1" &>/dev/null
    #sha=$(docker inspect --format='{{index .RepoDigests 0}}' balenalib/raspberry-pi-alpine:run | cut -d @ -f 2)
    sha=$(docker inspect --format='{{index .RepoDigests 0}}' "$1" | cut -d @ -f 2)
    echo ${sha}
}


compare_sha () {
    if [ "$1" == "$2" ];then
        return_value=$?
        return $return_value 
    else
        create_manifest
    fi
}

create_manifest(){
    pass
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
#compare_sha
#get_manifest_sha "vmnet8/alpine:$manifest_tag" "$arch"
#get_manifest_sha $@
#get_vmnet_sha $1 $2
#get_tag_sha $1
#create_manifest $1 $2 $3 $4
