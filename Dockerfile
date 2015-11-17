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
FROM ubuntu:14.04

# Add files from the context
ADD websphere-software /var/IBM/software
ADD im.secure.file /var/IBM/software/im.secure.file
ADD websphere-keyring-response-file.xml /var/IBM/software/websphere-keyring-response-file.xml
ADD websphere-response-file.xml /var/IBM/software/websphere-response-file.xml

# Get rid of dash - WebSphere requires Bash
RUN echo debconf dash/sh select "false" | debconf-set-selections
RUN echo debconf dash/sh seen "true" | debconf-set-selections
RUN dpkg-reconfigure -u dash

# Install unzip so we can extract the software images
RUN apt-get update && apt-get install -y \
    unzip

# Install the IBM Installation Manager
RUN mkdir /tmp/ibmim
WORKDIR /tmp/ibmim
RUN unzip /var/IBM/software/agent.installer.linux.*.zip && ./installc -acceptLicense

# Extract the WebSphere Application Server software images
RUN mkdir /tmp/websphere
WORKDIR /tmp/websphere
RUN for file in /var/IBM/software/was.repo.8550.developers*.zip; do unzip $file; done

RUN mkdir /tmp/websphere-sdk
WORKDIR /tmp/websphere-sdk
RUN for file in /var/IBM/software/was.repo.8550.java7*.zip; do unzip $file; done

WORKDIR /tmp
RUN echo "password" > im.master.password
RUN /opt/IBM/InstallationManager/eclipse/tools/imcl -acceptLicense input /var/IBM/software/websphere-keyring-response-file.xml -log /var/IBM/software/keyring-install.log -secureStorageFile /var/IBM/software/im.secure.file -masterPasswordFile /tmp/im.master.password
RUN /opt/IBM/InstallationManager/eclipse/tools/imcl -acceptLicense input /var/IBM/software/websphere-response-file.xml -log /var/IBM/software/websphere-install.log -secureStorageFile /var/IBM/software/im.secure.file -masterPasswordFile /tmp/im.master.password

# Cleanup
RUN rm -rf /tmp/ibmim /tmp/websphere /tmp/websphere-sdk

# Create and configure the websphere profile
WORKDIR /opt/IBM/WebSphere/AppServer
RUN bin/manageprofiles.sh -create -templatePath /opt/IBM/WebSphere/AppServer/profileTemplates/default -profileName AppSrv01 -cellName zblCell1 -nodeName zblCell1Node01

ADD configure.py /tmp
RUN bin/startServer.sh server1 && \
    bin/wsadmin.sh -f /tmp/configure.py && \
    bin/stopServer.sh server1

EXPOSE 9060 9080 9043 9443 2809 8880
ADD start-server.sh /usr/bin/
RUN chmod +x /usr/bin/start-server.sh
CMD /usr/bin/start-server.sh
