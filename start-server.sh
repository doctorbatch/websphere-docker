#!/bin/bash
/opt/IBM/WebSphere/AppServer/bin/startServer.sh server1
read -p "WebSphere Application Server is now running. Press [Enter] to shut down and exit container."
/opt/IBM/WebSphere/AppServer/bin/stopServer.sh server1
exit
