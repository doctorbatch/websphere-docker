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
## This script configures the environment for WebSphere Batch support by
## create the LRSCHED and PGC datasources (against Apache Derby), and deploying
## the LongRunningScheduler and PGCProxyController applications.
###############################################################################

import sys, os
import java.lang.System as jsys

#------------------------------------------------------------------------------
# Save the configuration
#------------------------------------------------------------------------------
def save():
    AdminConfig.save()

#------------------------------------------------------------------------------
# Deploys an application as a System app
#------------------------------------------------------------------------------
def installSystemApp(wasHome, appname):
    earPath     = wasHome + "/systemApps/" + appname + ".ear"
    AdminApp.install(earPath, ['-node', "zblCell1Node01", '-server', "server1", '-nopreCompileJSPs', '-distributeApp', '-noreloadEnabled', '-noprocessEmbeddedConfig', '-appname', appname, '-usedefaultbindings', '-zeroEarCopy',  '-installed.ear.destination', '$(WAS_INSTALL_ROOT)/systemApps'])

def configureLRS():
    AdminTask.modifyJobSchedulerAttribute("[-name deploymentTarget -value WebSphere:cell=zblCell1,node=zblCell1Node01,server=server1]")
    AdminTask.modifyJobSchedulerAttribute("[-name datasourceJNDIName -value jdbc/lrsched]")
    AdminTask.modifyLongRunningSchedulerAttribute("[-name databaseSchemaName -value LRSSCHEMA]")

#------------------------------------------------------------------------------
# Get the directory, as a string, where WAS is installed.
#------------------------------------------------------------------------------
def getWASHome():

    varMap = AdminConfig.getid("/Cell:zblCell1/Node:zblCell1Node01/VariableMap:/")
    entries = AdminConfig.list("VariableSubstitutionEntry", varMap)
    eList = entries.splitlines()
    for entry in eList:
        name =  AdminConfig.showAttribute(entry, "symbolicName")
        if name == "WAS_INSTALL_ROOT":
            value = AdminConfig.showAttribute(entry, "value")
            return value

    return java.lang.System.getenv('WAS_HOME')

###
# Main Entry
###

print "Configuring WAS Batch Environment"
WAS_HOME=getWASHome()

print "Creating PGC and LRSCHED datasources"
JDBCPID=AdminTask.createJDBCProvider('[-scope Node=zblCell1Node01,Server=server1 -databaseType Derby -providerType "Derby JDBC Provider" -implementationType "XA data source" -name "Derby JDBC Provider (XA)" -description "Derby embedded XA JDBC Provider. This provider is only configurable in version 6.0.2 and later nodes" -classpath [${DERBY_JDBC_DRIVER_PATH}/derby.jar ] -nativePath "" ]')
AdminTask.createDatasource(JDBCPID, '[-name LRSCHED -jndiName jdbc/lrsched -dataStoreHelperClassName com.ibm.websphere.rsadapter.DerbyDataStoreHelper -containerManagedPersistence true -componentManagedAuthenticationAlias -xaRecoveryAuthAlias -configureResourceProperties [[databaseName java.lang.String "${USER_INSTALL_ROOT}/gridDatabase/LRSCHED"]]]')
AdminTask.createDatasource(JDBCPID, '[-name PGC -jndiName jdbc/pgc -dataStoreHelperClassName com.ibm.websphere.rsadapter.DerbyDataStoreHelper -containerManagedPersistence true -componentManagedAuthenticationAlias -xaRecoveryAuthAlias -configureResourceProperties [[databaseName java.lang.String "${USER_INSTALL_ROOT}/gridDatabase/LRSCHED"]]]')


print "Installing PGCProxyController"
installSystemApp( WAS_HOME, "PGCProxyController" )


print "Installing Long Running Scheduler"
installSystemApp( WAS_HOME, "LongRunningScheduler" )

print "Configuring LRS"
configureLRS()


print "Saving configuration"
save()
