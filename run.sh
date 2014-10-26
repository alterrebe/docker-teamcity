#!/bin/bash

# Copy JDBC driver into the TeamCity folder
if [ ! -f ${TEAMCITY_DATA_PATH}/lib/jdbc/postgresql-*.jdbc41.jar ]; then
	mkdir -p ${TEAMCITY_DATA_PATH}/lib/jdbc
	cp ${CATALINA_HOME}/lib/postgresql-*.jdbc41.jar ${TEAMCITY_DATA_PATH}/lib/jdbc/
fi

# Here you can define some specific settings for CATALINA_OPTS, system properties, etc.

exec ${CATALINA_HOME}/bin/catalina.sh run
