FROM debian:7.7
MAINTAINER Alexey Melnikov <alexey.melnikov@aurea.com> - Aly Saleh <aly.saleh@aurea.com>

ENV ANT_VERSION=1.7.1 \
MCC_DIR=/mcc \
DCM_ENV=DCM \
ANT_HOME=/usr/bin/ant \
ANT_OPTS="-XX:MaxPermSize=900m -Xmx900m" \
CATALINA_HOME=/usr/share/tomcat7 \
CATALINA_BASE=/var/lib/tomcat7 \
PATH=$CATALINA_HOME/bin:$PATH

ARG JAVAHOME=/usr/lib/jvm/java-7-openjdk-amd64
ARG JDBC_DRIVERPATH=/usr/local/dcm/jdbc/postgresql-9.2-1004.jdbc3.jar
ARG JDBC_DRIVER=org.postgresql.Driver
ARG WEBSERVER=localhost
ARG WEBSERVERPORT=8080
ARG JDBC_URL=jdbc:postgresql://172.30.86.40:5432/mccdb
ARG DB_USERNAME=mccuser
ARG DB_PASSWORD=mccuser
ARG DATA_VOL_PATH=/data

WORKDIR /usr/local/

# Install JAVA 7, Tomcat 7
RUN \
    apt-get update -y && \
    apt-get install -y --no-install-recommends openjdk-7-jdk wget tomcat7 unzip &&\
    rm -rf /var/lib/apt/lists/*

# Install ANT7
RUN wget http://archive.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz && \
    tar -zxf apache-ant-$ANT_VERSION-bin.tar.gz && \
    rm -rf apache-ant-$ANT_VERSION-bin.tar.gz && \
    ln -s /usr/local/apache-ant-$ANT_VERSION/bin/ant /usr/bin/ant

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
    rm -rf /usr/local/dcm/setup.jar && \
    rm -rf ${MCC_DIR}/Apps/CompModeler

# Set DCM Properties
RUN sed -i "s#\[deploy.dms.MCCHOME\]=.*#\[deploy.dms.MCCHOME\]=${MCC_DIR}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.JAVAHOME\]=.*#\[deploy.dms.JAVAHOME\]=${JAVAHOME}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_DRIVERPATH\]=.*#\[deploy.dms.JDBC_DRIVERPATH\]=${JDBC_DRIVERPATH}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_DRIVER\]=.*#\[deploy.dms.JDBC_DRIVER\]=${JDBC_DRIVER}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.WEBSERVER\]=.*#\[deploy.dms.WEBSERVER\]=${WEBSERVER}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.WEBSERVERPORT\]=.*#\[deploy.dms.WEBSERVERPORT\]=${WEBSERVERPORT}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_URL\]=.*#\[deploy.dms.JDBC_URL\]=${JDBC_URL}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.DB_USERNAME\]=.*#\[deploy.dms.DB_USERNAME\]=${DB_USERNAME}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.DB_PASSWORD\]=.*#\[deploy.dms.DB_PASSWORD\]=${DB_PASSWORD}#g" ${MCC_DIR}/environments/DCM_Environment.properties

# Generate war
WORKDIR ${MCC_DIR}
RUN ant Install -Denvironment=$DCM_ENV
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
