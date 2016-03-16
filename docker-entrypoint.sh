#!/bin/bash

CATALINA_BASE="/usr/local/apache-tomcat"
CATALINA_HOME="/usr/local/apache-tomcat"

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

# Set DCM 2015 Properties
    sed -i "s#\[deploy.dms.MCCHOME\]=.*#\[deploy.dms.MCCHOME\]=${MCC_DIR}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.JAVAHOME\]=.*#\[deploy.dms.JAVAHOME\]=${JAVAHOME}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_DRIVERPATH\]=.*#\[deploy.dms.JDBC_DRIVERPATH\]=${JDBC_DRIVERPATH}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_DRIVER\]=.*#\[deploy.dms.JDBC_DRIVER\]=${JDBC_DRIVER}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.WEBSERVER\]=.*#\[deploy.dms.WEBSERVER\]=${WEBSERVER}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.WEBSERVERPORT\]=.*#\[deploy.dms.WEBSERVERPORT\]=${WEBSERVERPORT}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_URL\]=.*#\[deploy.dms.JDBC_URL\]=${JDBC_URL}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.DB_USERNAME\]=.*#\[deploy.dms.DB_USERNAME\]=${DB_USERNAME}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.DB_PASSWORD\]=.*#\[deploy.dms.DB_PASSWORD\]=${DB_PASSWORD}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[dcm.NIPRGatewayInstall\]=.*#\[dcm.NIPRGatewayInstall\]=false#g" ${MCC_DIR}/environments/templates/build.properties && \
    sed -i "s#\[dcm.WEBEFTInstall\]=.*#\[dcm.WEBEFTInstall\]=true#g" ${MCC_DIR}/environments/templates/build.properties && \
    sed -i "s#\[dcm.genJSPpages\]=.*#\[dcm.genJSPpages\]=true#g" ${MCC_DIR}/environments/templates/build.properties

# Set DCM Athene Properties
    sed -i "s#\[deploy.dms.MCCHOME\]=.*#\[deploy.dms.MCCHOME\]=${MCC_DIR}#g" ${ATHENE_DIR}/environments/Build_Environment.properties && \
    sed -i "s#\[deploy.dms.JAVAHOME\]=.*#\[deploy.dms.JAVAHOME\]=${JAVAHOME}#g" ${ATHENE_DIR}/environments/Build_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_DRIVERPATH\]=.*#\[deploy.dms.JDBC_DRIVERPATH\]=${JDBC_DRIVERPATH}#g" ${ATHENE_DIR}/environments/Build_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_DRIVER\]=.*#\[deploy.dms.JDBC_DRIVER\]=${JDBC_DRIVER}#g" ${ATHENE_DIR}/environments/Build_Environment.properties && \
    sed -i "s#\[deploy.dms.WEBSERVER\]=.*#\[deploy.dms.WEBSERVER\]=${WEBSERVER}#g" ${ATHENE_DIR}/environments/Build_Environment.properties && \
    sed -i "s#\[deploy.dms.WEBSERVERPORT\]=.*#\[deploy.dms.WEBSERVERPORT\]=${WEBSERVERPORT}#g" ${ATHENE_DIR}/environments/Build_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_URL\]=.*#\[deploy.dms.JDBC_URL\]=${JDBC_URL}#g" ${ATHENE_DIR}/environments/Build_Environment.properties && \
    sed -i "s#\[deploy.dms.DB_USERNAME\]=.*#\[deploy.dms.DB_USERNAME\]=${DB_USERNAME}#g" ${ATHENE_DIR}/environments/Build_Environment.properties && \
    sed -i "s#\[deploy.dms.DB_PASSWORD\]=.*#\[deploy.dms.DB_PASSWORD\]=${DB_PASSWORD}#g" ${ATHENE_DIR}/environments/Build_Environment.properties && \
    sed -i "s#\[deploy.dms.BASEDIR\]=.*#\[deploy.dms.BASEDIR\]=${BASEDIR}#g" ${ATHENE_DIR}/environments/Build_Environment.properties && \
    sed -i "s#\[deploy.dms.TABLESPACE\]=.*#\[deploy.dms.TABLESPACE\]=#g" ${ATHENE_DIR}/environments/Build_Environment.properties && \
    sed -i "s#\[deploy.dms.ORACLE_INDEX_TABLESPACE\]=.*#\[deploy.dms.ORACLE_INDEX_TABLESPACE\]=#g" ${ATHENE_DIR}/environments/Build_Environment.properties
    
    # Regenerate WAR with database
    cd ${MCC_DIR}
    ant Install -Denvironment=${DCM_ENV}

    cd ${ATHENE_DIR}
    ant -f MergeBuildModFiles.xml PrepareBuildFile -Denvironment=${ATHENE_ENV} && \
	ant PrepareEnvResources -Denvironment=${ATHENE_ENV} -Dproperty.modificationsfolder=${ATHENE_DIR}/mods/propertymods && \
	ant DevBuild -Denvironment=${ATHENE_ENV} -DuseXML=true -DskipTZX=false -DcheckTS=false
}

deploywar() {
    echo "DEPLOYING WAR..."
    
    cp ${ATHENE_DIR}/lib/*.war ${CATALINA_BASE}/webapps/

    # DMS
    rm -rf ${CATALINA_BASE}/webapps/DMS
    mkdir ${CATALINA_BASE}/webapps/DMS
    unzip -o ${CATALINA_BASE}/webapps/DMS.war -d ${CATALINA_BASE}/webapps/DMS
}

patchdbproperties() {
    echo "PATCHING DB PROPERTIES..."

    # DMS/WEB-INF/classes/CMEngine.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=${JDBC_URL}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/CMEngine.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${DB_USERNAME}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/CMEngine.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${DB_PASSWORD}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/CMEngine.properties

    # DMS/WEB-INF/classes/com/trilogy/fs/dms/DMSBackbone.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=${JDBC_URL}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/DMSBackbone.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${DB_USERNAME}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/DMSBackbone.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${DB_PASSWORD}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/DMSBackbone.properties

    # DMS/WEB-INF/classes/com/trilogy/fs/dms/core/lock/DMSDistributedLockService.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=${JDBC_URL}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/core/lock/DMSDistributedLockService.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${DB_USERNAME}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/core/lock/DMSDistributedLockService.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${DB_PASSWORD}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/core/lock/DMSDistributedLockService.properties

    # DMS/WEB-INF/classes/ivizgroup.properties
    sed -i "s#db.url=.*#db.url=${JDBC_URL}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/ivizgroup.properties
    sed -i "s#db.user=.*#db.user=${DB_USERNAME}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/ivizgroup.properties
    sed -i "s#db.password=.*#db.password=${DB_PASSWORD}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/ivizgroup.properties

    # DMS/WEB-INF/classes/ivizgroupLDAP.properties
    sed -i "s#db.url=.*#db.url=${JDBC_URL}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/ivizgroupLDAP.properties
    sed -i "s#db.user=.*#db.user=${DB_USERNAME}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/ivizgroupLDAP.properties
    sed -i "s#db.password=.*#db.password=${DB_PASSWORD}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/ivizgroupLDAP.properties

    # DMS/WEB-INF/classes/local.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=${JDBC_URL}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/local.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${DB_USERNAME}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/local.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${DB_PASSWORD}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/local.properties

    # DMS/WEB-INF/classes/mcc.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=${JDBC_URL}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/mcc.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${DB_USERNAME}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/mcc.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${DB_PASSWORD}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/mcc.properties

    # DMS/WEB-INF/classes/com/trilogy/html/gui/Multi.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=${JDBC_URL}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/trilogy/html/gui/Multi.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${DB_USERNAME}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/trilogy/html/gui/Multi.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${DB_PASSWORD}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/trilogy/html/gui/Multi.properties

    # DMS/WEB-INF/classes/UserAcl2ServiceServerBackbone.properties
    sed -i "s#JDBC_URL=.*#JDBC_URL=${JDBC_URL}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/UserAcl2ServiceServerBackbone.properties
    sed -i "s#DB_USERNAME=.*#DB_USERNAME=${DB_USERNAME}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/UserAcl2ServiceServerBackbone.properties
    sed -i "s#DB_PASSWORD=.*#DB_PASSWORD=${DB_PASSWORD}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/UserAcl2ServiceServerBackbone.properties

    # DMS/WEB-INF/classes/com/versata/adhoc/resources/adhoc.properties
    sed -i "s#jdbcUrl=.*#jdbcUrl=${JDBC_URL}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/versata/adhoc/resources/adhoc.properties
    sed -i "s#jdbcUser=.*#jdbcUser=${DB_USERNAME}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/versata/adhoc/resources/adhoc.properties
    sed -i "s#jdbcPassword=.*#jdbcPassword=${DB_PASSWORD}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/versata/adhoc/resources/adhoc.properties

    # DMS/WEB-INF/classes/mcc.xml
    sed -i "s#name=\"JDBC_URL\" value=\"[^\\""]*\"#name=\"JDBC_URL\" value=\"${JDBC_URL}\"#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/mcc.xml
    sed -i "s#name=\"DB_USERNAME\" value=\"[^\\""]*\"#name=\"DB_USERNAME\" value=\"${DB_USERNAME}\"#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/mcc.xml
    sed -i "s#name=\"DB_PASSWORD\" value=\"[^\\""]*\"#name=\"DB_PASSWORD\" value=\"${DB_PASSWORD}\"#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/mcc.xml
}

patchnipr() {
    if [ -n "$NIPR_USER" ] && [ -n "$NIPR_PASSWORD" ]; then
        echo "PATCHING NIPR PROPERTIES..."

        # DMS/WEB-INF/classes/com/trilogy/fs/dms/niprgateway/GatewayIntegration.properties
        sed -i "s#CustomerID=.*#CustomerID=${NIPR_USER}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/niprgateway/GatewayIntegration.properties
        sed -i "s#Password=.*#Password=${NIPR_PASSWORD}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/niprgateway/GatewayIntegration.properties

        # DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/AccountInformation.properties
        sed -i "s#CustomerID=.*#CustomerID=${NIPR_USER}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/AccountInformation.properties
        sed -i "s#Password=.*#Password=${NIPR_PASSWORD}#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/AccountInformation.properties
        
        # DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/DBIntegrationManager.properties
        if [ "$NIPR_BETA" == "true" -o "$NIPR_BETA" == "TRUE" ]; then
            sed -i "s#https://pdb-services.nipr.com/#https://pdb-services-beta.nipr.com/#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/PDBIntegrationManager.properties
        fi

        # DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/PDBReportProcessor.properties
        sed -i "s#UpdateMode.Process.PartyData=.*#UpdateMode.Process.PartyData=true#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/PDBReportProcessor.properties
        sed -i "s#UpdateMode.Process.ContactPointData=.*#UpdateMode.Process.ContactPointData=true#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/PDBReportProcessor.properties
        sed -i "s#UpdateMode.Process.LicenseData=.*#UpdateMode.Process.LicenseData=true#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/PDBReportProcessor.properties
        sed -i "s#UpdateMode.Process.AppointmentData=.*#UpdateMode.Process.AppointmentData=true#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/pdb/PDBReportProcessor.properties
    fi
}

postinstall() {
    # ADCM-2980 Exception in DCM Admin - Loaders Error - Edit Raw Data
    echo -e "\nPersonPartiesLoaderSpec.xml=Party.EditPersonParty" >> ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/tools/loader/ui/EditLoaderErrorPP.properties

    # ADCM-2509 Contract Kit XML Export Failed
    sed -i "s#KitSpecificationXML=.*#KitSpecificationXML=${MCC_DIR}/Apps/DMSComp/util/ContractKitSpec.xml#g" ${CATALINA_BASE}/webapps/DMS/WEB-INF/classes/com/trilogy/fs/dms/contract/ContractExportAsXMLProviderServlet.properties
}

if [ "$GENERATE_DATABASE" == "true" -o "$GENERATE_DATABASE" == "TRUE" ]; then
    generatedb
fi

# deploy DCM
deploywar
patchdbproperties
patchnipr
postinstall

${CATALINA_BASE}/bin/catalina.sh run
