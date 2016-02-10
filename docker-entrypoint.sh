#!/bin/bash

CATALINA_BASE="/var/lib/tomcat7"
CATALINA_HOME="/usr/share/tomcat7"

if [ -z "$JDBC_URL" ]; then
    echo "JDBC_URL environment variable required"
    exit 1
fi

if [ -z "$DB_USERNAME" ]; then
    echo "DB_USERNAME environment variable required"
    exit 1
fi

if [ -z "$DB_PASSWORD" ]; then
    echo "DB_PASSWORD environment variable required"
    exit 1
fi

generatedb() {
    echo "GENERATING DATABASE..."

    # Set DCM Properties
    sed -i "s#\[deploy.dms.JDBC_URL\]=.*#\[deploy.dms.JDBC_URL\]=${JDBC_URL}#g" ${MCC_DIR}/environments/DCM_Environment.properties
    sed -i "s#\[deploy.dms.DB_USERNAME\]=.*#\[deploy.dms.DB_USERNAME\]=${DB_USERNAME}#g" ${MCC_DIR}/environments/DCM_Environment.properties
    sed -i "s#\[deploy.dms.DB_PASSWORD\]=.*#\[deploy.dms.DB_PASSWORD\]=${DB_PASSWORD}#g" ${MCC_DIR}/environments/DCM_Environment.properties
    sed -i "s#\[deploy.dms.JDBC_DRIVERPATH\]=.*#\[deploy.dms.JDBC_DRIVERPATH\]=${JDBC_DRIVERPATH}#g" ${MCC_DIR}/environments/DCM_Environment.properties
    sed -i "s#\[deploy.dms.JDBC_DRIVER\]=.*#\[deploy.dms.JDBC_DRIVER\]=${JDBC_DRIVER}#g" ${MCC_DIR}/environments/DCM_Environment.properties
    
    # Regenerate WAR with database
    cd ${MCC_DIR}
    ant Install -Denvironment=${DCM_ENV}
}

deploywar() {
    echo "DEPLOYING WAR..."
    
    cp ${MCC_DIR}/buildoutput/*.war $CATALINA_BASE/webapps/

    # DMS
    mkdir $CATALINA_BASE/webapps/DMS
    unzip -o $CATALINA_BASE/webapps/DMS.war -d $CATALINA_BASE/webapps/DMS
}

patchdbproperties() {
    echo "PATCHING DB PROPERTIES..."

    # DMS/WEB-INF/classes/CMEngine.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=${JDBC_URL}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/CMEngine.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${DB_USERNAME}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/CMEngine.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${DB_PASSWORD}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/CMEngine.properties

    # DMS/WEB-INF/classes/com/trilogy/fs/dms/DMSBackbone.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=${JDBC_URL}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/DMSBackbone.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${DB_USERNAME}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/DMSBackbone.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${DB_PASSWORD}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/DMSBackbone.properties

    # DMS/WEB-INF/classes/com/trilogy/fs/dms/core/lock/DMSDistributedLockService.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=${JDBC_URL}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/core/lock/DMSDistributedLockService.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${DB_USERNAME}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/core/lock/DMSDistributedLockService.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${DB_PASSWORD}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/core/lock/DMSDistributedLockService.properties

    # DMS/WEB-INF/classes/ivizgroup.properties
    sed -i "s#db.url=.*#db.url=${JDBC_URL}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/ivizgroup.properties
    sed -i "s#db.user=.*#db.user=${DB_USERNAME}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/ivizgroup.properties
    sed -i "s#db.password=.*#db.password=${DB_PASSWORD}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/ivizgroup.properties

    # DMS/WEB-INF/classes/ivizgroupLDAP.properties
    sed -i "s#db.url=.*#db.url=${JDBC_URL}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/ivizgroupLDAP.properties
    sed -i "s#db.user=.*#db.user=${DB_USERNAME}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/ivizgroupLDAP.properties
    sed -i "s#db.password=.*#db.password=${DB_PASSWORD}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/ivizgroupLDAP.properties

    # DMS/WEB-INF/classes/local.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=${JDBC_URL}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/local.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${DB_USERNAME}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/local.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${DB_PASSWORD}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/local.properties

    # DMS/WEB-INF/classes/mcc.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=${JDBC_URL}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/mcc.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${DB_USERNAME}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/mcc.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${DB_PASSWORD}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/mcc.properties

    # DMS/WEB-INF/classes/com/trilogy/html/gui/Multi.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=${JDBC_URL}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/trilogy/html/gui/Multi.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${DB_USERNAME}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/trilogy/html/gui/Multi.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${DB_PASSWORD}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/trilogy/html/gui/Multi.properties

    # DMS/WEB-INF/classes/UserAcl2ServiceServerBackbone.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=${JDBC_URL}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/UserAcl2ServiceServerBackbone.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${DB_USERNAME}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/UserAcl2ServiceServerBackbone.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${DB_PASSWORD}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/UserAcl2ServiceServerBackbone.properties

    # DMS/WEB-INF/classes/com/versata/adhoc/resources/adhoc.properties
    sed -i "s#jdbcUrl=.*#jdbcUrl=${JDBC_URL}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/versata/adhoc/resources/adhoc.properties
    sed -i "s#jdbcUser=.*#jdbcUser=${DB_USERNAME}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/versata/adhoc/resources/adhoc.properties
    sed -i "s#jdbcPassword=.*#jdbcPassword=${DB_PASSWORD}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/versata/adhoc/resources/adhoc.properties

    # DMS/WEB-INF/classes/mcc.xml
    sed -i "s#name=\"JDBC_URL\" value=\"[^\\""]*\"#name=\"JDBC_URL\" value=\"${JDBC_URL}\"#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/mcc.xml
    sed -i "s#name=\"DB_USERNAME\" value=\"[^\\""]*\"#name=\"DB_USERNAME\" value=\"${DB_USERNAME}\"#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/mcc.xml
    sed -i "s#name=\"DB_PASSWORD\" value=\"[^\\""]*\"#name=\"DB_PASSWORD\" value=\"${DB_PASSWORD}\"#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/mcc.xml
}

patchnipr() {
    if [ -n "$NIPR_USER" ] && [ -n "$NIPR_PASSWORD" ]; then
        echo "PATCHING NIPR PROPERTIES..."

        # DMS/WEB-INF/classes/com/trilogy/fs/dms/niprgateway/GatewayIntegration.properties
        sed -i "s#CustomerID=.*#CustomerID=${NIPR_USER}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/niprgateway/GatewayIntegration.properties
        sed -i "s#Password=.*#Password=${NIPR_PASSWORD}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/niprgateway/GatewayIntegration.properties

        # DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/AccountInformation.properties
        sed -i "s#CustomerID=.*#CustomerID=${NIPR_USER}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/AccountInformation.properties
        sed -i "s#Password=.*#Password=${NIPR_PASSWORD}#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/AccountInformation.properties
        
        # DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/DBIntegrationManager.properties
        if [ "$NIPR_BETA" == "true" -o "$NIPR_BETA" == "TRUE" ]; then
            sed -i "s#https://pdb-services.nipr.com/#https://pdb-services-beta.nipr.com/#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/PDBIntegrationManager.properties
        fi

        # DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/PDBReportProcessor.properties
        sed -i "s#UpdateMode.Process.PartyData=.*#UpdateMode.Process.PartyData=true#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/PDBReportProcessor.properties
        sed -i "s#UpdateMode.Process.ContactPointData=.*#UpdateMode.Process.ContactPointData=true#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/PDBReportProcessor.properties
        sed -i "s#UpdateMode.Process.LicenseData=.*#UpdateMode.Process.LicenseData=true#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/PDBReportProcessor.properties
        sed -i "s#UpdateMode.Process.AppointmentData=.*#UpdateMode.Process.AppointmentData=true#g" $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/PDBReportProcessor.properties
    fi
}

postinstall() {
    # DMS/WEB-INF/classes/com/trilogy/fs/dms/tools/loader/ui/EditLoaderErrorPP.properties
    echo '\nPersonPartiesLoaderSpec.xml=Party.EditPersonParty' >> $CATALINA_BASE/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/tools/loader/ui/EditLoaderErrorPP.properties
}

if [ "$GENERATE_DATABASE" == "true" -o "$GENERATE_DATABASE" == "TRUE" ]; then
    generatedb
fi

# deploy DCM
deploywar
patchdbproperties
patchnipr
postinstall

$CATALINA_HOME/bin/catalina.sh run
