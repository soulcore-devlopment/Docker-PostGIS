FROM ubuntu:trusty

MAINTAINER Alberto Asuero "alberto@geographica.gs"

# Environment
ENV POSTGRES_PASSWD postgres 
ENV ROOTDIR /usr/local/
ENV POSTGIS_DATABASE postgis
ENV POSTGIS_CONTRIB /usr/local/share/postgresql/contrib/postgis-1.5 
ENV POSTGRES_DATA_FOLDER /data 
ENV PG_VERSION 9.1.2 
ENV GEOS_VERSION 3.4.2 
ENV PROJ4_VERSION 4.8.0 
ENV POSTGIS_VERSION 1.5.8
ENV LOCALE en_US
ENV ENCODING UTF-8

# Load assets
WORKDIR $ROOTDIR/

ADD https://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.bz2 $ROOTDIR/src/
ADD http://download.osgeo.org/geos/geos-${GEOS_VERSION}.tar.bz2 $ROOTDIR/src/
ADD http://download.osgeo.org/proj/proj-${PROJ4_VERSION}.tar.gz $ROOTDIR/src/
ADD packages/proj4-patch/src/pj_datums.c $ROOTDIR/src/
ADD http://download.osgeo.org/proj/proj-datumgrid-1.5.tar.gz $ROOTDIR/src/
ADD packages/proj4-patch/nad/epsg $ROOTDIR/src/
ADD packages/proj4-patch/nad/PENR2009.gsb $ROOTDIR/src/
ADD http://download.osgeo.org/postgis/source/postgis-${POSTGIS_VERSION}.tar.gz $ROOTDIR/src/
ADD packages/postgis-patch/spatial_ref_sys.sql $ROOTDIR/src/
ADD packages/compile.sh $ROOTDIR/src/
#ADD packages/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
#ADD packages/run.sh /usr/local/bin/run.sh

# Compilation
RUN chmod 777 src/compile.sh
RUN src/compile.sh --encoding ${ENCODING} --locale ${LOCALE} --pg-version ${PG_VERSION} --geos-version ${GEOS_VERSION} \
  --proj4-version ${PROJ4_VERSION} --postgis-version ${POSTGIS_VERSION}

# Final touches
EXPOSE 5432

# Volumes
VOLUME $POSTGRES_DATA_FOLDER

COPY packages/docker-entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh
RUN chown postgres:postgres /usr/local/bin/docker-entrypoint.sh

# RUN ln -s /usr/local/bin/docker-entrypoint.sh / # backwards compat
# ENTRYPOINT ["docker-entrypoint.sh"]
# CMD ["postgres"]

RUN ln -s /usr/local/bin/docker-entrypoint.sh / # backwards compat
ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]

CMD ["postgres"]

#CMD /usr/local/bin/run.sh