#!/bin/bash

source sha_function.sh

sha1=$(get_manifest_sha $1 $2 $3 $4)
#sha1=$(get_manifest_sha $@)
sha2=$(get_manifest_sha "vmnet8/alpine" latest amd64)
echo "1 is  ${sha1}"
echo "2 is ${sha2}"
#sha3=$(get_tag_sha $1)
#echo $sha3

compare_sha $1 $2
