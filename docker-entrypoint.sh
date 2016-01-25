#!/bin/bash

if [ -z "$POSTGRES_CONNECTION" ]; then
    echo "POSTGRES_CONNECTION environment variable required"
    exit 1
fi

if [ -z "$POSTGRES_USERNAME" ]; then
    echo "POSTGRES_USERNAME environment variable required"
    exit 1
fi

if [ -z "$POSTGRES_PASSWORD" ]; then
    echo "POSTGRES_PASSWORD environment variable required"
    exit 1
fi

#if [ -z "$NIPR_USER" ]; then
#    echo "NIPR_USER environment variable required"
#    exit 1
#fi

#if [ -z "$NIPR_PASSWORD" ]; then
#    echo "NIPR_PASSWORD environment variable required"
#    exit 1
#fi

generatedb() {
    echo "GENERATING DATABASE..."

    # Set DCM Properties
    sed -i "s#\[deploy.dms.JDBC_URL\]=.*#\[deploy.dms.JDBC_URL\]=jdbc:postgresql://${POSTGRES_CONNECTION}#g" ${MCC_DIR}/environments/DCM_Environment.properties
    sed -i "s#\[deploy.dms.DB_USERNAME\]=.*#\[deploy.dms.DB_USERNAME\]=${POSTGRES_USERNAME}#g" ${MCC_DIR}/environments/DCM_Environment.properties
    sed -i "s#\[deploy.dms.DB_PASSWORD\]=.*#\[deploy.dms.DB_PASSWORD\]=${POSTGRES_PASSWORD}#g" ${MCC_DIR}/environments/DCM_Environment.properties

    # Regenerate WAR with database
    cd ${MCC_DIR}
    ant Install -Denvironment=${DCM_ENV}
    cp ${MCC_DIR}/buildoutput/DMS.war /usr/local/apache-tomcat/webapps/
}

patchproperties() {
    echo "PATCHING PROPERTIES..."

    # DMS/WEB-INF/classes/CMEngine.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=jdbc:postgresql://${POSTGRES_CONNECTION}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/CMEngine.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${POSTGRES_USERNAME}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/CMEngine.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${POSTGRES_PASSWORD}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/CMEngine.properties

    # DMS/WEB-INF/classes/com/trilogy/fs/dms/DMSBackbone.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=jdbc:postgresql://${POSTGRES_CONNECTION}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/DMSBackbone.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${POSTGRES_USERNAME}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/DMSBackbone.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${POSTGRES_PASSWORD}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/DMSBackbone.properties

    # DMS/WEB-INF/classes/com/trilogy/fs/dms/core/lock/DMSDistributedLockService.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=jdbc:postgresql://${POSTGRES_CONNECTION}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/core/lock/DMSDistributedLockService.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${POSTGRES_USERNAME}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/core/lock/DMSDistributedLockService.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${POSTGRES_PASSWORD}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/core/lock/DMSDistributedLockService.properties

    # DMS/WEB-INF/classes/ivizgroup.properties
    sed -i "s#db.url=.*#db.url=jdbc:postgresql://${POSTGRES_CONNECTION}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/ivizgroup.properties
    sed -i "s#db.user=.*#db.user=${POSTGRES_USERNAME}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/ivizgroup.properties
    sed -i "s#db.password=.*#db.password=${POSTGRES_PASSWORD}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/ivizgroup.properties

    # DMS/WEB-INF/classes/ivizgroupLDAP.properties
    sed -i "s#db.url=.*#db.url=jdbc:postgresql://${POSTGRES_CONNECTION}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/ivizgroupLDAP.properties
    sed -i "s#db.user=.*#db.user=${POSTGRES_USERNAME}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/ivizgroupLDAP.properties
    sed -i "s#db.password=.*#db.password=${POSTGRES_PASSWORD}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/ivizgroupLDAP.properties

    # DMS/WEB-INF/classes/local.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=jdbc:postgresql://${POSTGRES_CONNECTION}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/local.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${POSTGRES_USERNAME}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/local.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${POSTGRES_PASSWORD}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/local.properties

    # DMS/WEB-INF/classes/mcc.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=jdbc:postgresql://${POSTGRES_CONNECTION}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/mcc.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${POSTGRES_USERNAME}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/mcc.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${POSTGRES_PASSWORD}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/mcc.properties

    # DMS/WEB-INF/classes/com/trilogy/html/gui/Multi.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=jdbc:postgresql://${POSTGRES_CONNECTION}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/com/trilogy/html/gui/Multi.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${POSTGRES_USERNAME}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/com/trilogy/html/gui/Multi.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${POSTGRES_PASSWORD}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/com/trilogy/html/gui/Multi.properties

    # DMS/WEB-INF/classes/UserAcl2ServiceServerBackbone.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=jdbc:postgresql://${POSTGRES_CONNECTION}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/UserAcl2ServiceServerBackbone.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${POSTGRES_USERNAME}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/UserAcl2ServiceServerBackbone.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${POSTGRES_PASSWORD}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/UserAcl2ServiceServerBackbone.properties

    # DMS/WEB-INF/classes/com/versata/adhoc/resources/adhoc.properties
    sed -i "s#jdbcUrl=.*#jdbcUrl=jdbc:postgresql://${POSTGRES_CONNECTION}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/com/versata/adhoc/resources/adhoc.properties
    sed -i "s#jdbcUser=.*#jdbcUser=${POSTGRES_USERNAME}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/com/versata/adhoc/resources/adhoc.properties
    sed -i "s#jdbcPassword=.*#jdbcPassword=${POSTGRES_PASSWORD}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/com/versata/adhoc/resources/adhoc.properties

    # DMS/WEB-INF/classes/mcc.xml
    sed -i "s#name=\"JDBC_URL\" value=\"[^\\""]*\"#name=\"JDBC_URL\" value=\"jdbc:postgresql://${POSTGRES_CONNECTION}\"#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/mcc.xml
    sed -i "s#name=\"DB_USERNAME\" value=\"[^\\""]*\"#name=\"DB_USERNAME\" value=\"${POSTGRES_USERNAME}\"#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/mcc.xml
    sed -i "s#name=\"DB_PASSWORD\" value=\"[^\\""]*\"#name=\"DB_PASSWORD\" value=\"${POSTGRES_PASSWORD}\"#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/mcc.xml
    
    # DMS/WEB-INF/classes/com/trilogy/fs/dms/niprgateway/GatewayIntegration.properties
    sed -i "s#CustomerID=.*#CustomerID=${NIPR_USER}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/niprgateway/GatewayIntegration.properties
    sed -i "s#Password=.*#Password=${NIPR_PASSWORD}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/niprgateway/GatewayIntegration.properties

    # DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/AccountInformation.properties
    sed -i "s#CustomerID=.*#CustomerID=${NIPR_USER}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/AccountInformation.properties
    sed -i "s#Password=.*#Password=${NIPR_PASSWORD}#g" /usr/local/apache-tomcat/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/AccountInformation.properties
}

if [ "$GENERATE_DATABASE" == "TRUE" ]; then
    generatedb
else
    cp ${MCC_DIR}/buildoutput/DMS.war /usr/local/apache-tomcat/webapps/
    mkdir /usr/local/apache-tomcat/webapps/DMS
    unzip -o /usr/local/apache-tomcat/webapps/DMS.war -d /usr/local/apache-tomcat/webapps/DMS
    patchproperties
fi

catalina.sh run
