FROM java:7
MAINTAINER Alexey Melnikov <alexey.melnikov@aurea.com> - Aly Saleh <aly.saleh@aurea.com>

ENV ANT_VERSION 1.7.1
ENV MCC_DIR /mcc
ENV AMFAM_DIR /amfam
ENV DCM_ENV DCM
ENV AMFAM_ENV Dev
ENV CATALINA_HOME /usr/share/tomcat7
ENV CATALINA_BASE /var/lib/tomcat7
ENV PATH $CATALINA_HOME/bin:$PATH
ENV ANT_HOME /usr/bin/ant
ENV ANT_OPTS "-XX:MaxPermSize=900m -Xmx900m"

ARG JAVAHOME=/usr/lib/jvm/java-7-openjdk
ARG JDBC_DRIVERPATH=/usr/local/dcm/jdbc/postgresql-9.2-1004.jdbc3.jar
ARG JDBC_DRIVER=org.postgresql.Driver
ARG WEBSERVER=localhost
ARG WEBSERVERPORT=8083
ARG JDBC_URL=jdbc:postgresql://172.30.86.40:5435/mccdb
ARG DB_USERNAME=mccuser
ARG DB_PASSWORD=mccuser
ARG DATA_VOL_PATH=/data
ARG SVN_PASSWORD="bCm&{:F>nuZ'23zN"
ARG SVN_USER=service.dcm.teamcity

WORKDIR /usr/local/
RUN apt-get update -y

# Install ANT7
RUN wget http://archive.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz && \
    tar -zxf apache-ant-$ANT_VERSION-bin.tar.gz && \
    rm -rf apache-ant-$ANT_VERSION-bin.tar.gz && \
    ln -s /usr/local/apache-ant-$ANT_VERSION/bin/ant /usr/bin/ant

# Install Tomcat7 and subversion
RUN apt-get install -y tomcat7 && \
    apt-get install -y subversion

#Checkout AmFam from SVN
RUN svn co https://subversion.devfactory.com/repos/FinSvcs_AMFAM/branches/AMFAM_upgrade_2015 &&
    AMFAM_DIR --username SVN_USER --password SVN_PASSWORD --no-auth-cache --non-interactive

# Copy DCM Installer
USER root
RUN mkdir -p /usr/local/dcm
RUN mkdir -p $DATA_VOL_PATH
COPY installer/setup.jar /usr/local/dcm/
RUN mkdir -p /usr/local/dcm/jdbc
COPY /jdbc/*.jar /usr/local/dcm/jdbc/
COPY /jdbc/*.jar $CATALINA_HOME/lib/
WORKDIR /
RUN yes $MCC_DIR | java -classpath /usr/local/dcm/setup.jar run -console && \
    rm -rf /usr/local/dcm/setup.jar

# Set DCM 2015 Properties
RUN sed -i "s#\[deploy.dms.MCCHOME\]=.*#\[deploy.dms.MCCHOME\]=${MCC_DIR}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.JAVAHOME\]=.*#\[deploy.dms.JAVAHOME\]=${JAVAHOME}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_DRIVERPATH\]=.*#\[deploy.dms.JDBC_DRIVERPATH\]=${JDBC_DRIVERPATH}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_DRIVER\]=.*#\[deploy.dms.JDBC_DRIVER\]=${JDBC_DRIVER}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.WEBSERVER\]=.*#\[deploy.dms.WEBSERVER\]=${WEBSERVER}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.WEBSERVERPORT\]=.*#\[deploy.dms.WEBSERVERPORT\]=${WEBSERVERPORT}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_URL\]=.*#\[deploy.dms.JDBC_URL\]=${JDBC_URL}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.DB_USERNAME\]=.*#\[deploy.dms.DB_USERNAME\]=${DB_USERNAME}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.DB_PASSWORD\]=.*#\[deploy.dms.DB_PASSWORD\]=${DB_PASSWORD}#g" ${MCC_DIR}/environments/DCM_Environment.properties

##Checkout AMFAM Branch##

# Set DCM AmFam Properties
RUN sed -i "s#\[deploy.dms.MCCHOME\]=.*#\[deploy.dms.MCCHOME\]=${MCC_DIR}#g" ${AMFAM_DIR}/environments/Dev_Environment.properties && \
    sed -i "s#\[deploy.dms.JAVAHOME\]=.*#\[deploy.dms.JAVAHOME\]=${JAVAHOME}#g" ${AMFAM_DIR}/environments/Dev_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_DRIVERPATH\]=.*#\[deploy.dms.JDBC_DRIVERPATH\]=${JDBC_DRIVERPATH}#g" ${AMFAM_DIR}/environments/Dev_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_DRIVER\]=.*#\[deploy.dms.JDBC_DRIVER\]=${JDBC_DRIVER}#g" ${AMFAM_DIR}/environments/Dev_Environment.properties && \
    sed -i "s#\[deploy.dms.WEBSERVER\]=.*#\[deploy.dms.WEBSERVER\]=${WEBSERVER}#g" ${AMFAM_DIR}/environments/Dev_Environment.properties && \
    sed -i "s#\[deploy.dms.WEBSERVERPORT\]=.*#\[deploy.dms.WEBSERVERPORT\]=${WEBSERVERPORT}#g" ${AMFAM_DIR}/environments/Dev_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_URL\]=.*#\[deploy.dms.JDBC_URL\]=${JDBC_URL}#g" ${AMFAM_DIR}/environments/Dev_Environment.properties && \
    sed -i "s#\[deploy.dms.DB_USERNAME\]=.*#\[deploy.dms.DB_USERNAME\]=${DB_USERNAME}#g" ${AMFAM_DIR}/environments/Dev_Environment.properties && \
    sed -i "s#\[deploy.dms.DB_PASSWORD\]=.*#\[deploy.dms.DB_PASSWORD\]=${DB_PASSWORD}#g" ${AMFAM_DIR}/environments/Dev_Environment.properties
    
# Generate war
WORKDIR ${MCC_DIR}
RUN ant Install -Denvironment=$DCM_ENV
RUN ant PrepareBuildFiles -Dbuild.mods=${AMFAM_DIR}/build/build_mods.xml &&
        -DPrepEnvResources.mods=${AMFAM_DIR}/build/PrepareEnvResources_mods.xml &&
        -DRunTools.mods=${AMFAM_DIR}/build/RunTools_mods.xml &&
        -DUniquenessFile=${AMFAM_DIR}/build/build_unique.xml -DOutputDir=${AMFAM_DIR}

WORKDIR ${AMFAM_DIR}
RUN ant PrepareEnvResources -Denvironment=$AMFAM_ENV -Dproperty.modificationsfolder=${AMFAM_DIR}/mods/propertymods && \
    ant DevBuild -Denvironment=$AMFAM_ENV -DuseXML=true && \
    rm -rf ${AMFAM_DIR}/*.log

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
