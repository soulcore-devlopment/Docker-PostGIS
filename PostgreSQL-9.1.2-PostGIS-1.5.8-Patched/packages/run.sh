#!/bin/bash

# Create data store
mkdir -p ${POSTGRES_DATA_FOLDER}
chown postgres:postgres ${POSTGRES_DATA_FOLDER}
chmod 700 ${POSTGRES_DATA_FOLDER}
echo "postgres:${POSTGRES_PASSWD}" | chpasswd -e

function create_postgis()
{
    # plpgsql already exists
    # su postgres -c "createdb ${POSTGIS_DATABASE} && createlang plpgsql ${POSTGIS_DATABASE}" \
    su postgres -c "createdb ${POSTGIS_DATABASE}" \
    && su postgres -c "psql -h localhost -U postgres -p 5432 -d ${POSTGIS_DATABASE} -f ${POSTGIS_CONTRIB}/postgis.sql" \
    && su postgres -c "psql -h localhost -U postgres -p 5432 -d ${POSTGIS_DATABASE} -f ${POSTGIS_CONTRIB}/spatial_ref_sys.sql"
    # && su postgres -c "psql -h localhost -U postgres -p 5432 -tc \"UPDATE pg_database SET datistemplate = false, datconnlimit=-1, datallowconn=true WHERE datname = '${POSTGIS_DATABASE}';\""
    # not working
    # && su postgres -c "psql -h localhost -U postgres -p 5432 -d ${POSTGIS_DATABASE} -f ${POSTGIS_CONTRIB}/postgis_comments.sql"
}

function check_postgis()
{
    su postgres -c "psql -h localhost -U postgres -p 5432 -tc \"SELECT 1 FROM pg_database WHERE datname = '${POSTGIS_DATABASE}';\"" | grep -q 1 || create_postgis
}

function setup_database()
{
    su postgres -c "initdb  --encoding=${ENCODING} --locale=${LOCALE}.${ENCODING} --lc-collate=${LOCALE}.${ENCODING}  --lc-monetary=${LOCALE}.${ENCODING}  --lc-numeric=${LOCALE}.${ENCODING}  --lc-time=${LOCALE}.${ENCODING}  -D ${POSTGRES_DATA_FOLDER}"

    # Modify basic configutarion
    su postgres -c "echo \"host all all 0.0.0.0/0 md5\" >> $POSTGRES_DATA_FOLDER/pg_hba.conf"
    su postgres -c "echo \"listen_addresses='*'\" >> $POSTGRES_DATA_FOLDER/postgresql.conf"

    # Establish postgres user password and run the database
    su postgres -c "pg_ctl -w -D ${POSTGRES_DATA_FOLDER} start" \
    && su postgres -c "psql -h localhost -U postgres -p 5432 -c \"alter role postgres password '${POSTGRES_PASSWD}';\"" \
    && su postgres -c "pg_ctl -w -D ${POSTGRES_DATA_FOLDER} stop"
}

# Check if data folder is empty. If it is, start the dataserver
if ! ["$(ls -A ${POSTGRES_DATA_FOLDER})" ]; then
    setup_database
fi

# Start the database
su postgres -c "postgres -D $POSTGRES_DATA_FOLDER" && check_postgis