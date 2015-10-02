#!/bin/bash

# Ensure we won't kick the dead horse:
set -e

# Copy JDBC driver into the TeamCity folder
if [ ! -f ${TEAMCITY_DATA_PATH}/lib/jdbc/postgresql-*.jdbc41.jar ]; then
	mkdir -p ${TEAMCITY_DATA_PATH}/lib/jdbc
	cp ${CATALINA_HOME}/lib/postgresql-*.jdbc41.jar ${TEAMCITY_DATA_PATH}/lib/jdbc/
fi

# We want to migrate mutable folders to the attached volume
migrate_data() {
	local localPath=$1
	local volumePath=$2
	local volumeParentDir=$( echo $volumePath | sed 's,[^/]*$,,' )

	if [ ! -d ${TEAMCITY_DATA_PATH}${volumePath} ]; then
		if [ -d ${localPath} ]; then # move existing data
			mkdir -p ${TEAMCITY_DATA_PATH}${volumeParentDir}
			cp -a ${localPath} ${TEAMCITY_DATA_PATH}${volumeParentDir}
			rm -rf ${localPath}
		else
			mkdir -p ${TEAMCITY_DATA_PATH}${volumePath}
		fi
		ln -s ${TEAMCITY_DATA_PATH}${volumePath} ${localPath}
	fi
}

migrate_data /tmp /tmp
migrate_data /logs /logs
migrate_data ${CATALINA_HOME}/logs /tomcat/logs
migrate_data ${CATALINA_HOME}/temp /tomcat/temp
migrate_data ${CATALINA_HOME}/work /tomcat/work
if [ ! -e ${TEAMCITY_DATA_PATH}/logs/tomcat ]; then
	ln -s ${TEAMCITY_DATA_PATH}/tomcat/logs ${TEAMCITY_DATA_PATH}/logs/tomcat
fi

# Here you can define some specific settings for CATALINA_OPTS, system properties, etc.

exec ${CATALINA_HOME}/bin/catalina.sh run
