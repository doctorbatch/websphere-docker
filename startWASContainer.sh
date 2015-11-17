#!/bin/bash
#
# Copyright 2015 ZBL Services, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###############################################################################

#
# Runs the websphere container identified by image $1 on docker-machine $2 (default by default).
###

MACHINE=default
if [ ! -z $2 ]; then
  echo "Using machine $2"
  MACHINE=$2
fi

eval $(docker-machine env $MACHINE)
docker run -it -p 9080:9080 -p 9060:9060 -p 2809:2809 -p 9443:9443 -p 9043:9043 -p 8880:8880 $1
