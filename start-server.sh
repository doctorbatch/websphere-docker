#!/bin/bash

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
