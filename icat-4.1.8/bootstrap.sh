#!/bin/bash

until psql -h irods-db -U postgres -c '\l'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

git clone https://github.com/km4rcus/irods_scc_ruleset /tmp/scc_ruleset
cd /tmp/scc_ruleset; make install

if [[ ! -e /etc/irods/setup_responses ]]; then

   RODS_PASSWORD=$1

   # generate configuration responses
   /opt/irods/genresp.sh /etc/irods/setup_responses

   if [ -n "$RODS_PASSWORD" ]
      then
         sed -i "14s/.*/$RODS_PASSWORD/" /etc/irods/setup_responses
   fi

   # set up the iCAT database
   /opt/irods/setupdb.sh /etc/irods/setup_responses
   # set up iRODS
   /opt/irods/config.sh /etc/irods/setup_responses
   # Add the scc-ruleset to server config
   /opt/irods/prepend_ruleset.py /etc/irods/server_config.json scc-ruleset 

   # create SCC resources
   mkdir -p /mnt/cmcc_vault/tape/rs1-tape
   mkdir -p /mnt/cmcc_vault/tape/rs2-tape
   mkdir -p /mnt/cmcc_vault/tsm/rs1-tsm
   mkdir -p /mnt/cmcc_vault/tsm/rs2-tsm
   mkdir -p /mnt/cmcc_vault/ddn1/rs1-ddn1
   mkdir -p /mnt/cmcc_vault/ddn1/rs2-ddn1
   mkdir -p /mnt/cmcc_vault/home/rs1-home
   mkdir -p /mnt/cmcc_vault/dl380
   chown -R irods:irods /mnt/cmcc_vault

   su - irods -c "iadmin mkresc rs1-tape unixfilesystem ${HOSTNAME}:/mnt/cmcc_vault/tape/rs1-tape"
   su - irods -c "iadmin mkresc rs2-tape unixfilesystem ${HOSTNAME}:/mnt/cmcc_vault/tape/rs2-tape"
   su - irods -c "iadmin mkresc rs1-tsm unixfilesystem ${HOSTNAME}:/mnt/cmcc_vault/tsm/rs1-tsm"
   su - irods -c "iadmin mkresc rs2-tsm unixfilesystem ${HOSTNAME}:/mnt/cmcc_vault/tsm/rs2-tsm"
   su - irods -c "iadmin mkresc rs1-ddn1 unixfilesystem ${HOSTNAME}:/mnt/cmcc_vault/ddn1/rs1-ddn1"
   su - irods -c "iadmin mkresc rs2-ddn1 unixfilesystem ${HOSTNAME}:/mnt/cmcc_vault/ddn1/rs2-ddn1"
   su - irods -c "iadmin mkresc rs1-home unixfilesystem ${HOSTNAME}:/mnt/cmcc_vault/home/rs1-home"
   su - irods -c "iadmin mkresc rsDl380 unixfilesystem ${HOSTNAME}:/mnt/cmcc_vault/dl380"
   su - irods -c "iadmin mkresc rr-tsm roundrobin"
   su - irods -c "iadmin mkresc rr-tape roundrobin"
   su - irods -c "iadmin mkresc rr-ddn1 roundrobin"
   su - irods -c "iadmin addchildtoresc rr-tsm rs1-tsm"
   su - irods -c "iadmin addchildtoresc rr-tsm rs2-tsm"
   su - irods -c "iadmin addchildtoresc rr-tape rs1-tape"
   su - irods -c "iadmin addchildtoresc rr-tape rs2-tape"
   su - irods -c "iadmin addchildtoresc rr-ddn1 rs1-ddn1"
   su - irods -c "iadmin addchildtoresc rr-ddn1 rs2-ddn1"
   su - irods -c "iadmin mkresc pt-tsm passthru '' 'write=1.0;read=1.0'"
   su - irods -c "iadmin mkresc pt-tape passthru '' 'write=1.0;read=1.0'"
   su - irods -c "iadmin mkresc pt-ddn1 passthru '' 'write=1.0;read=1.0'"
   su - irods -c "iadmin mkresc pt-home passthru '' 'write=1.0;read=1.0'"
   su - irods -c "iadmin mkresc pt-dl380 passthru '' 'write=1.0;read=1.0'"
   su - irods -c "iadmin addchildtoresc pt-tsm rr-tsm"
   su - irods -c "iadmin addchildtoresc pt-tape rr-tape"
   su - irods -c "iadmin addchildtoresc pt-ddn1 rr-ddn1"
   su - irods -c "iadmin addchildtoresc pt-home rs1-home"
   su - irods -c "iadmin addchildtoresc pt-dl380 rsDl380"
   su - irods -c "iadmin mkresc rr-tier2 roundrobin"
   su - irods -c "iadmin mkresc pt-tier2 passthru '' 'write=1.0;read=1.0'"
   su - irods -c "iadmin addchildtoresc rr-tier2 pt-home"
   su - irods -c "iadmin addchildtoresc pt-tier2 rr-tier2"

   # change default resource 
   sed -i '/^acSetRescSch/ s/demoResc/pt-tier2/' /etc/irods/core.re

else
   service irods start
fi

# this script must end with a persistent foreground process
tail -f /var/lib/irods/iRODS/server/log/rodsLog.*
