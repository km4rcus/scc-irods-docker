FROM tomcat:7.0-jre8
MAINTAINER Marco Mancini (marco.mancini@cmcc.it)

RUN wget https://code.renci.org/gf/download/frsrelease/243/2742/irods-rest.war -O /usr/local/tomcat/webapps/irods-rest.war

#ADD irods-rest.war /usr/local/tomcat/webapps/
ADD irods-rest.properties /etc/irods-ext/

CMD ["catalina.sh", "run"]
