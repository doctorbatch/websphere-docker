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

##
# This script is the foreground process in the docker container that launches
# the WAS server, and waits on the server process to exit. Once the server
# process exits, the container can terminate.
###############################################################################

trap stopserver INT

WAS_HOME=/opt/IBM/WebSphere/AppServer
PROFILE=AppSrv01
SERVER=server1

function stopserver() {
  $WAS_HOME/bin/stopServer.sh $SERVER -profileName $PROFILE
  exit
}

function isRunning( ) {
  return `(kill -s 0 $1 2>&1) > /dev/null`
}

rm $WAS_HOME/profiles/$PROFILE/logs/$SERVER/startServer.log
$WAS_HOME/bin/startServer.sh $SERVER -profileName $PROFILE 2>&1
PID_LINE=`grep 'ADMU3000I' $WAS_HOME/profiles/$PROFILE/logs/$SERVER/startServer.log`
PID=`echo $PID_LINE | sed 's/..*process id is \([0-9][0-9]*\)$/\1/g'`

echo Waiting on WebSphere Server Process $PID

while isRunning $PID; do sleep 5; done
echo "WebSphere Application Server process $PID has terminated. Goodbye."
