set -x
PGS1_DIR=/home/jenkins/PGSpider/PGS1/
PGS1_PORT=5433
PGS2_DIR=/home/jenkins/PGSpider/PGS2/
PGS2_PORT=5434
DB_NAME=postgres
export PATH=$PATH:$POSTGRES_HOME/bin
CURR_PATH=$(pwd)

if [[ "--start" == $1 ]]
then
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
psql -p $PGS1_PORT -U postgres $DB_NAME < pgspider_selectfunc1.dat

# Setup PGSpider2
psql -p $PGS2_PORT -U postgres $DB_NAME < pgspider_selectfunc2.dat
