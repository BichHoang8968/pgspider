PGS1_DB=setcluster2_db1
DATA_PATH=$INIT_DATA_PATH

function clean_docker_img()
{
  if [ "$(docker ps -aq -f name=^/${1}$)" ]; then
    if [ "$(docker ps -aq -f status=exited -f status=created -f name=^/${1}$)" ]; then
        docker rm ${1}
    else
        docker rm $(docker stop ${1})
    fi
  fi
}

export http_proxy=
if [[ "--start" == $1 ]]
then
  #Start PGSpider nodes
  #Start PGS1
  cd ${PGS1_DIR}/bin/
  if ! [ -d "../${PGS1_DB}" ];
  then
    ./initdb ../${PGS1_DB}
    sed -i "s~#port = .*~port = $PGS1_PORT~g" ../${PGS1_DB}/postgresql.conf
    sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PGS1_DB}/pg_hba.conf
    ./pg_ctl -D ../${PGS1_DB} start #-l ../log.pgs1
    sleep 2
    ./createdb -p $PGS1_PORT pgspider
  fi
  if ! ./pg_isready -p $PGS1_PORT
  then
    echo "Start PGS1"
    sed -i 's/host    all             all             127.0.0.1\/32            trust/host    all             all             127.0.0.1\/32            md5/' ../${PGS1_DB}/pg_hba.conf
    ./pg_ctl -D ../${PGS1_DB} start #-l ../log.pgs1
    sleep 2
  fi

  cd $DATA_PATH

  # Start GridDB server
  griddb_image='griddb-5.1.0'
  griddb_container_name=griddb_svr
  clean_docker_img ${griddb_container_name}
  docker run -d --name ${griddb_container_name} --network="host" -e GRIDDB_CLUSTER_NAME=griddbfdwTestSetcluster -e GRIDDB_PASSWORD=testadmin -e NOTIFICATION_ADDRESS=239.0.0.1 -e NOTIFICATION_PORT=31999 ${griddb_image}

fi

#PGSpider should be already started
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "create user pgspider with password 'pgspider';"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "grant all privileges on database pgspider to pgspider;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pgspider;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "ALTER USER pgspider WITH NOSUPERUSER;"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "CREATE ROLE pgspider2 LOGIN SUPERUSER PASSWORD 'pgspider2';"
$PGS1_DIR/bin/psql -p $PGS1_PORT pgspider -c "GRANT ALL PRIVILEGES ON SCHEMA public TO pgspider;"

cd $DATA_PATH
# Initialize data for GridDB
echo "Init data for GridDB..."
rm /tmp/tbl_grid.data
cp tbl_grid.data /tmp/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${GRIDDB_CLIENT}/bin
gcc griddb_init.c -o griddb_init -I${GRIDDB_CLIENT}/client/c/include -L${GRIDDB_CLIENT}/bin -lgridstore
# Wait until docker container of GridDB ready
until [ $(docker exec griddb_svr /bin/bash -c 'gs_stat -u admin/testadmin | grep \"nodeStatus\"' | awk -F': ' '{print $2}' | tr -d '\"'| sed 's/,$//') == "ACTIVE" ]
do
  sleep 5
done
./griddb_init 239.0.0.1 31999 griddbfdwTestSetcluster admin testadmin /tmp/tbl_grid.data 0