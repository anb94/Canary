#!/bin/bash

function recursive_comm {
    if [ "$#" -eq 2 ]; then
        comm -12 "$1" "$2"
    else
        currFile="$1"
        shift
        comm -12 "$currFile" <(recursive_comm "$@")
    fi
}


if [ "$#" -lt "2" ]; then
    echo "multi_comm requires 2 or more files"
    exit 1
fi

recursive_comm "$@"
