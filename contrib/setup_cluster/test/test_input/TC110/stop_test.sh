#PGSpider nodes
PGS1_DB=setcluster3_db1
#Postgres nodes
PG1_PORT=5432
PG1_DB=setcluster3_db2

CURR_PATH=$(pwd)

if [[ "--stop" == $1 ]]
then
    #stop PGSpider nodes
    #stop PGS1
    cd ${PGS1_DIR}/bin/
    if ./pg_isready -p $PGS1_PORT
    then
      echo "Stop PGS1"
      ./pg_ctl -D ../${PGS1_DB} stop #-l ../log.pgs1
      sleep 2
    fi

    pkill -9 pgspider
  
    #stop Postgres nodes
    #stop PG1
    cd ${PG1_DIR}/bin/
    if ./pg_isready -p $PG1_PORT
    then
      echo "stop PG1"
      ./pg_ctl -D ../${PG1_DB} stop #-l ../log.pg1
    fi

    #clean DB folder
    cd ${PGS1_DIR}
    rm -rf ${PGS1_DB} || true
    cd ${PG1_DIR}
    rm -rf ${PG1_DB} || true
    
    # clean up objstorage
    docker compose -p objstoragetest stop minio
    docker compose -p objstoragetest stop azurite
    docker compose -p objstoragetest stop gcs
    docker compose -p objstoragetest rm -fsv minio
    docker compose -p objstoragetest rm -fsv azurite
    docker compose -p objstoragetest rm -fsv gcs
    docker volume rm objstoragetest_minio-data
    docker volume rm objstoragetest_azurite-data
    docker volume rm objstoragetest_gcs-data

    # clean influxdb server if exists
    container_name_v2='influxdb_server_v2'
    container_name_v1='influxdb_server_v1'

    if [ "$(docker ps -aq -f name=^/${container_name_v2}$)" ]; then
        if [ "$(docker ps -aq -f status=exited -f status=created -f name=^/${container_name_v2}$)" ]; then
            docker rm ${container_name_v2}
        else
            docker rm $(docker stop ${container_name_v2})
        fi
    fi

    if [ "$(docker ps -aq -f name=^/${container_name_v1}$)" ]; then
        if [ "$(docker ps -aq -f status=exited -f status=created -f name=^/${container_name_v1}$)" ]; then
            docker rm ${container_name_v1}
        else
            docker rm $(docker stop ${container_name_v1})
        fi
    fi

    # Clean for Parquet and start Minio server
    if [ "$(docker ps -aqf name=^/${MINIO_CONTAINER}$)" ]; then
        docker rm -f ${MINIO_CONTAINER}
    fi

    #clean redmine_server
    cd ${REDMINE_HOME}
    docker compose down

    #clean Gitlab
    cd ${GITLAB_HOME}
    docker compose down
fi
