set -x
PGS1_DIR=/home/jenkins/PGSpider/PGS1/
PGS1_PORT=5433
PGS2_DIR=/home/jenkins/PGSpider/PGS2/
PGS2_PORT=5434
DB_NAME=postgres
CURR_PATH=$(pwd)

if [[ "--start" == $1 ]]
then
  #Start PGS1
  cd ${PGS1_DIR}/bin/
  if ! [ -d "../${PGS1_DB}" ];
  then
    ./initdb ../${PGS1_DB}
    sed -i "s~#port = 4813.*~port = $PGS1_PORT~g" ../${PGS1_DB}/postgresql.conf
    ./pg_ctl -D ../${PGS1_DB} start #-l ../log.pg1
    sleep 2
    ./createdb -p $PGS1_PORT postgres
  fi
  if ! ./pg_isready -p $PGS1_PORT
  then
    echo "Start PG1"
    ./pg_ctl -D ../${PGS1_DB} start #-l ../log.pg1
    sleep 2
  fi
  #Start PGS2
  if ! [ -d "../${PGS2_DB}" ];
  then
    ./initdb ../${PGS2_DB}
    sed -i "s~#port = 4813.*~port = $PGS2_PORT~g" ../${PGS2_DB}/postgresql.conf
    ./pg_ctl -D ../${PGS2_DB} start #-l ../log.pg2
    sleep 2
    ./createdb -p $PGS2_PORT postgres
  fi
  if ! ./pg_isready -p $PGS2_PORT
  then
    echo "Start PG2"
    ./pg_ctl -D ../${PGS2_DB} start #-l ../log.pg2
    sleep 2
  fi
  # Start MySQL
  if ! [[ $(systemctl status mysqld.service) == *"active (running)"* ]]
  then
    echo "Start MySQL Server"
    systemctl start mysqld.service
    sleep 2
  fi
  # Start InfluxDB server
  if ! [[ $(systemctl status influxdb) == *"active (running)"* ]]
  then
    echo "Start InfluxDB Server"
    systemctl start influxdb
    sleep 2
  fi
fi

cd $CURR_PATH

# Setup SQLite
rm /tmp/pgtest.db
sqlite3 /tmp/pgtest.db < sqlite_selectfunc.dat

# Setup Mysql
mysql -uroot -pMysql_1234 < mysql_selectfunc.dat

# Setup InfluxDB
influx -import -path=./influx_selectfunc.data -precision=ns

# Setup PGSpider1
$PGS1_DIR/bin/psql -p $PGS1_PORT $DB_NAME < pgspider_selectfunc1.dat

# Setup PGSpider2
$PGS2_DIR/bin/psql -p $PGS2_PORT $DB_NAME < pgspider_selectfunc2.dat