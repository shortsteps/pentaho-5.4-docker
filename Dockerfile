FROM ubuntu:14.04

# Init ENV
#ENV LANG it_IT.UTF-8
#ENV LANGUAGE it

ENV DEBIAN_FRONTEND noninteractive

ENV BISERVER_VERSION 5.4
ENV BISERVER_TAG 5.4.0.1-130

ENV PENTAHO_HOME /opt/pentaho

COPY jdk1.7.0_80/ /opt/jdk1.7.0_80/

#Install Updates, Dependencies and Oracle JDK 7
RUN apt-get update; apt-get install zip netcat -y; \
    apt-get install wget unzip vim python-software-properties software-properties-common -y; \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Apply JAVA_HOME
ENV PENTAHO_JAVA_HOME $JAVA_HOME
ENV PENTAHO_JAVA_HOME /opt/jdk1.7.0_80/
ENV JAVA_HOME /opt/jdk1.7.0_80/
ENV PATH $PATH:/opt/jdk1.7.0_80/bin

RUN mkdir ${PENTAHO_HOME}; useradd -s /bin/bash -d ${PENTAHO_HOME} pentaho; chown pentaho:pentaho ${PENTAHO_HOME}

USER pentaho

# Download Pentaho BI Server 
RUN /usr/bin/wget --progress=dot:giga http://downloads.sourceforge.net/project/pentaho/Business%20Intelligence%20Server/${BISERVER_VERSION}/biserver-ce-${BISERVER_TAG}.zip -O /tmp/biserver-ce-${BISERVER_TAG}.zip; \
    /usr/bin/unzip -q /tmp/biserver-ce-${BISERVER_TAG}.zip -d  $PENTAHO_HOME; \
    rm -f /tmp/biserver-ce-${BISERVER_TAG}.zip $PENTAHO_HOME/biserver-ce/promptuser.sh; \
    sed -i -e 's/\(exec ".*"\) start/\1 run/' $PENTAHO_HOME/biserver-ce/tomcat/bin/startup.sh; \
    chmod +x $PENTAHO_HOME/biserver-ce/start-pentaho.sh; 
    #sed -i -e 's/requestParameterAuthenticationEnabled=false/requestParameterAuthenticationEnabled=true/' $PENTAHO_HOME/biserver-ce/pentaho-solutions/system/security.properties; \
    #sed -i -e 's/CATALINA_OPTS="-Xms1024m -Xmx2048m -XX:MaxPermSize=256m -Dsun.rmi.dgc.client.gcInterval=3600000 -Dsun.rmi.dgc.server.gcInterval=3600000"/CATALINA_OPTS="-Xms1024m -Xmx2048m -XX:MaxPermSize=256m -Dsun.rmi.dgc.client.gcInterval=3600000 -Dsun.rmi.dgc.server.gcInterval=3600000 -Dfile.encoding=UTF-8"/' $PENTAHO_HOME/biserver-ce/start-pentaho.sh;

# Script di avvio del servizio
COPY ./start $PENTAHO_HOME/start

USER root
RUN chown -R pentaho:pentaho ${PENTAHO_HOME}

USER pentaho

WORKDIR /opt/pentaho
EXPOSE 8080

# Tramite la definizione del Volume, i file sotto /opt/pentaho sono rimappati in maniera persistente sul FS dell'host
VOLUME /opt/pentaho

# All'avvio del container si avvia il servizio (se si stoppa manualmente il servizio, si stoppa anche il container)
CMD ["sh", "start"]

