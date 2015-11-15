#!/bin/bash

trap stopserver INT

WAS_HOME=/opt/IBM/WebSphere/AppServer
PROFILE=AppSrv01
SERVER=server1

function stopserver() {
  $WAS_HOME/bin/stopServer.sh $SERVER -profileName $PROFILE
  exit
}

$WAS_HOME/bin/startServer.sh $SERVER -profileName $PROFILE
tail -f $WAS_HOME/profiles/$PROFILE/logs/$SERVER/SystemOut.log
