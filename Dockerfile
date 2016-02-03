FROM java:7
MAINTAINER Alexey Melnikov <alexey.melnikov@aurea.com> - Aly Saleh <aly.saleh@aurea.com>

ENV ANT_VERSION 1.7.1
ENV TOMCAT_VERSION 7.0.67
ENV MCC_DIR /mcc
ENV DCM_ENV DCM

WORKDIR /usr/local/
RUN apt-get update -y

# Install ANT7
RUN wget http://archive.apache.org/dist/ant/binaries/apache-ant-$ANT_VERSION-bin.tar.gz && \
    tar -zxf apache-ant-$ANT_VERSION-bin.tar.gz && \
    rm -rf apache-ant-$ANT_VERSION-bin.tar.gz && \
    ln -s /usr/local/apache-ant-$ANT_VERSION/bin/ant /usr/bin/ant

ENV ANT_HOME /usr/bin/ant
ENV ANT_OPTS "-XX:MaxPermSize=900m -Xmx900m"

# Install Tomcat7
RUN apt-get install -y tomcat7

ENV CATALINA_HOME /usr/share/tomcat7
ENV PATH $CATALINA_HOME/bin:$PATH

# Install PostgreSQL temporarily to install DCM (key servers: hkp://keyserver.ubuntu.com:80 or hkp://p80.pool.sks-keyservers.net:80)
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && apt-get install -y python-software-properties software-properties-common postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3

USER postgres
RUN /etc/init.d/postgresql start && \
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" && \
    createdb -O docker docker && \
    echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf && \
    cp /etc/postgresql/9.3/main/* /var/lib/postgresql/9.3/main/

# Copy DCM Installer
USER root
RUN mkdir -p /usr/local/dcm
COPY installer/setup.jar /usr/local/dcm/
RUN mkdir -p /usr/local/dcm/jdbc
COPY /jdbc/*.jar /usr/local/dcm/jdbc/
COPY /jdbc/*.jar $CATALINA_HOME/lib/
WORKDIR /
RUN yes $MCC_DIR | java -classpath /usr/local/dcm/setup.jar run -console && \
    rm -rf /usr/local/dcm/setup.jar

# Set DCM Properties
RUN sed -i "s#\[deploy.dms.MCCHOME\]=.*#\[deploy.dms.MCCHOME\]=${MCC_DIR}#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.JAVAHOME\]=.*#\[deploy.dms.JAVAHOME\]=/usr/lib/jvm/java-7-openjdk#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_DRIVERPATH\]=.*#\[deploy.dms.JDBC_DRIVERPATH\]=/usr/local/dcm/jdbc/postgresql-9.2-1004.jdbc3.jar#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_DRIVER\]=.*#\[deploy.dms.JDBC_DRIVER\]=org.postgresql.Driver#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.WEBSERVER\]=.*#\[deploy.dms.WEBSERVER\]=localhost#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.WEBSERVERPORT\]=.*#\[deploy.dms.WEBSERVERPORT\]=8080#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.JDBC_URL\]=.*#\[deploy.dms.JDBC_URL\]=jdbc:postgresql://127.0.0.1:5432/docker#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.DB_USERNAME\]=.*#\[deploy.dms.DB_USERNAME\]=docker#g" ${MCC_DIR}/environments/DCM_Environment.properties && \
    sed -i "s#\[deploy.dms.DB_PASSWORD\]=.*#\[deploy.dms.DB_PASSWORD\]=docker#g" ${MCC_DIR}/environments/DCM_Environment.properties

# Generate war
WORKDIR ${MCC_DIR}
RUN /etc/init.d/postgresql start && \
    ant Install -Denvironment=$DCM_ENV

USER root

# Enterprise Prerequisites
ENV CLASSPATH /usr/local/apache-ant-${ANT_VERSION}/lib/*:/usr/local/dcm/jdbc/*:$CLASSPATH
COPY installer/DCMEnterpriseInstaller.jar ${MCC_DIR}
COPY installer/dcminstall.sh /usr/local/dcm/

# Easier Feature
RUN /etc/init.d/postgresql start && \
    bash /usr/local/dcm/dcminstall.sh $MCC_DIR $DCM_ENV EASIER

# DCM Port
EXPOSE 8080

# DCM Volume
VOLUME ["/usr/local/apache-tomcat/webapps/"]

# Entrypoint
COPY docker-entrypoint.sh ./docker-entrypoint.sh
RUN chmod +x ./docker-entrypoint.sh
ENTRYPOINT ["./docker-entrypoint.sh"]
