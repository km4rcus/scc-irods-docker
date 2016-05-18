FROM ubuntu:14.04
MAINTAINER danb@renci.org

RUN apt-get update ; apt-get upgrade -y

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql wget libcurl4-gnutls-dev make git build-essential libcurl3

#install iRODS
RUN wget ftp://ftp.renci.org/pub/irods/releases/4.1.8/ubuntu14/irods-database-plugin-postgres-1.8-ubuntu14-x86_64.deb -O /tmp/irods-dbplugin.deb
RUN wget ftp://ftp.renci.org/pub/irods/releases/4.1.8/ubuntu14/irods-icat-4.1.8-ubuntu14-x86_64.deb -O /tmp/irods-icat.deb
RUN wget ftp://ftp.renci.org/pub/irods/releases/4.1.8/ubuntu14/irods-dev-4.1.8-ubuntu14-x86_64.deb -O /tmp/irods-dev.deb
RUN wget ftp://ftp.renci.org/pub/irods/releases/4.1.8/ubuntu14/irods-runtime-4.1.8-ubuntu14-x86_64.deb -O /tmp/irods-runtime.deb

# install package dependencies to prevent Docker build from erring out
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y `dpkg -I /tmp/irods-icat.deb | sed -n 's/^ Depends: //p' | sed 's/,//g'`
RUN dpkg -i /tmp/irods-icat.deb

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y `dpkg -I /tmp/irods-dbplugin.deb | sed -n 's/^ Depends: //p' | sed 's/,//g'`
RUN dpkg -i /tmp/irods-dbplugin.deb

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y `dpkg -I /tmp/irods-dev.deb | sed -n 's/^ Depends: //p' | sed 's/,//g'`
RUN dpkg -i /tmp/irods-dev.deb

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y `dpkg -I /tmp/irods-runtime.deb | sed -n 's/^ Depends: //p' | sed 's/,//g'`
RUN dpkg -i /tmp/irods-runtime.deb

# install netcdf plugin
RUN git clone https://github.com/km4rcus/irods_netcdf.git /tmp/irods-netcdf

RUN /tmp/irods-netcdf/api/packaging/build.sh
RUN /tmp/irods-netcdf/microservices/packaging/build.sh

RUN dpkg -i /tmp/irods-netcdf/api/build/irods-api-plugin-netcdf-1.0.deb
RUN dpkg -i /tmp/irods-netcdf/microservices/build/irods-microservice-plugin-netcdf-1.0.deb

# install microservice netcdf calcDate
RUN git clone https://github.com/km4rcus/irods_microservice_netcdfDate.git /tmp/msiDate

RUN cd /tmp/msiDate; make install

#
RUN mkdir /opt/irods

ADD ./genresp.sh /opt/irods/genresp.sh
ADD ./setupdb.sh /opt/irods/setupdb.sh
ADD ./config.sh /opt/irods/config.sh
ADD ./bootstrap.sh /opt/irods/bootstrap.sh
ADD ./prepend_ruleset.py /opt/irods/prepend_ruleset.py

RUN chmod a+x /opt/irods/*.sh
RUN chmod a+x /opt/irods/*.py

EXPOSE 1248 1247

VOLUME [ "/rules" ]

ENTRYPOINT [ "/opt/irods/bootstrap.sh" ]
