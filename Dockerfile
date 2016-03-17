FROM debian:7.7
MAINTAINER Alexey Melnikov <alexey.melnikov@aurea.com> - Aly Saleh <aly.saleh@aurea.com>

ENV ANT_VERSION=1.6.5 \
    TOMCAT_VERSION=7.0.68 \
    MCC_DIR=/mcc \
    ATHENE_DIR=/athene \
    CATALINA_HOME=/usr/local/apache-tomcat \
    CATALINA_BASE=/usr/local/apache-tomcat \
    ANT_HOME=/usr/bin/ant \
    JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64/ \
    #JAVA_HOME=/usr/lib/jvm/java-7-oracle \
    ANT_OPTS="-XX:MaxPermSize=900m -Xmx900m" \
    PATH=$CATALINA_HOME/bin:$JAVA_HOME/bin:$PATH \
    DCM_ENV=DCM \
    ATHENE_ENV=Build
    
ARG JDBC_DRIVERPATH=/usr/local/dcm/jdbc/postgresql-9.2-1004.jdbc3.jar
ARG JDBC_DRIVER=org.postgresql.Driver
ARG WEBSERVER=localhost
ARG WEBSERVERPORT=8080
ARG JDBC_URL=jdbc:postgresql://172.30.86.40:5436/mccdb
ARG DB_USERNAME=mccuser
ARG DB_PASSWORD=mccuser
ARG DATA_VOL_PATH=/data
ARG BASEDIR=${ATHENE_DIR}
ARG SVN_PASSWORD="bCm&{:F>nuZ'23zN"
ARG SVN_USER=service.dcm.teamcity
ARG ATHENE_SVN_URL=https://subversion.devfactory.com/repos/Aviva/branches/aakash/R1C7_DefectsFix

WORKDIR /usr/local/

#RUN apt-add-repository -y ppa:webupd8team/java \
# && apt-get update -y \
# && echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
# && apt-get install -y wget unzip subversion oracle-java7-installer

# Install JAVA 7
RUN \
    apt-get update -y && \
    apt-get install -y openjdk-7-jdk wget unzip subversion &&\
    rm -rf /var/lib/apt/lists/*

# Install ANT
RUN wget http://archive.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz && \
    tar -zxf apache-ant-$ANT_VERSION-bin.tar.gz && \
    rm -rf apache-ant-$ANT_VERSION-bin.tar.gz && \
    ln -s /usr/local/apache-ant-$ANT_VERSION/bin/ant /usr/bin/ant

# Install Tomcat7 and subversion
RUN wget http://www.eu.apache.org/dist/tomcat/tomcat-7/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz && \
    tar -zxf apache-tomcat-$TOMCAT_VERSION.tar.gz && \
    rm -rf apache-tomcat-$TOMCAT_VERSION.tar.gz && \
    mv apache-tomcat-$TOMCAT_VERSION apache-tomcat

# Checkout Athene from SVN
RUN svn co $ATHENE_SVN_URL $ATHENE_DIR --username $SVN_USER --password $SVN_PASSWORD --no-auth-cache --non-interactive

# Copy DCM Installer
USER root
RUN mkdir -p /usr/local/dcm && \
    mkdir -p /usr/local/dcm/jdbc && \
    mkdir -p $DATA_VOL_PATH

COPY installer/setup.jar /usr/local/dcm/
COPY /jdbc/*.jar /usr/local/dcm/jdbc/
COPY /jdbc/*.jar $CATALINA_HOME/lib/

WORKDIR /
RUN yes $MCC_DIR | java -classpath /usr/local/dcm/setup.jar run -console && \
    rm -rf /usr/local/dcm/setup.jar

# Set DCM 2015 Properties
RUN sed -i "s#\[deploy.dms.MCCHOME\]=.*#\[deploy.dms.MCCHOME\]=${MCC_DIR}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.JAVAHOME\]=.*#\[deploy.dms.JAVAHOME\]=${JAVA_HOME}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_DRIVERPATH\]=.*#\[deploy.dms.JDBC_DRIVERPATH\]=${JDBC_DRIVERPATH}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_DRIVER\]=.*#\[deploy.dms.JDBC_DRIVER\]=${JDBC_DRIVER}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.WEBSERVER\]=.*#\[deploy.dms.WEBSERVER\]=${WEBSERVER}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.WEBSERVERPORT\]=.*#\[deploy.dms.WEBSERVERPORT\]=${WEBSERVERPORT}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_URL\]=.*#\[deploy.dms.JDBC_URL\]=${JDBC_URL}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.DB_USERNAME\]=.*#\[deploy.dms.DB_USERNAME\]=${DB_USERNAME}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.DB_PASSWORD\]=.*#\[deploy.dms.DB_PASSWORD\]=${DB_PASSWORD}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#dcm.NIPRGatewayInstall=.*#dcm.NIPRGatewayInstall=false#g" ${MCC_DIR}/environments/templates/build.properties && \
    sed -i "s#dcm.WEBEFTInstall=.*#dcm.WEBEFTInstall=true#g" ${MCC_DIR}/environments/templates/build.properties && \
    sed -i "s#dcm.genJSPpages=.*#dcm.genJSPpages=true#g" ${MCC_DIR}/environments/templates/build.properties

# Set DCM Athene Properties
RUN sed -i "s#\[deploy.dms.MCCHOME\]=.*#\[deploy.dms.MCCHOME\]=${MCC_DIR}#g" ${ATHENE_DIR}/environments/Build_Environment.properties && \
    sed -i "s#\[deploy.dms.JAVAHOME\]=.*#\[deploy.dms.JAVAHOME\]=${JAVA_HOME}#g" ${ATHENE_DIR}/environments/Build_Environment.properties && \
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
    
# Install DCM 2015
WORKDIR ${MCC_DIR}
RUN ant Install -Denvironment=$DCM_ENV

# Generate DCM Athene WAR 
WORKDIR ${ATHENE_DIR}
RUN ant -f MergeBuildModFiles.xml PrepareBuildFile -Denvironment=$ATHENE_ENV && \
	ant PrepareEnvResources -Denvironment=$ATHENE_ENV -Dproperty.modificationsfolder=${ATHENE_DIR}/mods/propertymods && \
	ant DevBuild -Denvironment=$ATHENE_ENV -DuseXML=true -DskipTZX=false -DcheckTS=false

USER root

# DCM Port
EXPOSE 8080

# DCM WAR Volume
VOLUME ["${CATALINA_BASE}/webapps/"]
# Data Volume
VOLUME ["${DATA_VOL_PATH}"]

# Entrypoint
COPY docker-entrypoint.sh ./docker-entrypoint.sh
RUN chmod +x ./docker-entrypoint.sh
ENTRYPOINT ["./docker-entrypoint.sh"]
