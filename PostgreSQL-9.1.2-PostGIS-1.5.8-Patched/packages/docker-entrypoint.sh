#!/bin/bash
set -e

if [ "$1" = 'postgres' ]; then
    # chown -R postgres "$PGDATA"

    # Create data store
    mkdir -p ${POSTGRES_DATA_FOLDER}
    chown postgres:postgres ${POSTGRES_DATA_FOLDER}
    chmod 700 ${POSTGRES_DATA_FOLDER}
    echo "postgres:${POSTGRES_PASSWD}" | chpasswd -e

    if ! [ -z "$(ls -A "$PGDATA")" ]; then
        #gosu postgres initdb
        su postgres -c "initdb  --encoding=${ENCODING} --locale=${LOCALE}.${ENCODING} --lc-collate=${LOCALE}.${ENCODING}  --lc-monetary=${LOCALE}.${ENCODING}  --lc-numeric=${LOCALE}.${ENCODING}  --lc-time=${LOCALE}.${ENCODING} -D ${POSTGRES_DATA_FOLDER}"

        su postgres -c "pg_ctl -w -D ${POSTGRES_DATA_FOLDER} start" \
        && su postgres -c "psql -h localhost -U postgres -p 5432 -tc \"alter role postgres password '${POSTGRES_PASSWD}';\"" \
        && su postgres -c "pg_ctl -w -D ${POSTGRES_DATA_FOLDER} stop"
    fi

    #exec gosu postgres "$@"
    su postgres -c "postgres -D ${POSTGRES_DATA_FOLDER}"

    #psql <<EOF
    #\x
    #SELECT * FROM foo;
    #EOF
fi

exec "$@"