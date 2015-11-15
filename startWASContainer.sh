#!/bin/bash
#
# Runs the websphere container identified by image $1 on docker-machine $2 (default by default).
###

MACHINE=default
if [-z ""$2"]
  MACHINE=$2
fi

eval $(docker-machine env $MACHINE)
docker run -it -p 9080:9080 -p 9060:9060 -p 2809:2809 -p 9443:9443 -p 9043:9043 -p 8880:8880 $1
