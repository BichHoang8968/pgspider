source $(pwd)/../environment_variable.config

if [[ "--start" == $1 ]]
then
  # Start PostgreSQL
  cd ${POSTGRES_HOME}/bin/
  if ! [ -d "../databases" ];
  then
    ./initdb ../databases
    sed -i 's/#port = 5432.*/port = 15432/' ../databases/postgresql.conf
    ./pg_ctl -D ../databases start
    sleep 2
    ./createdb -p 15432 postgres
  fi
  if ! ./pg_isready -p 15432
  then
    echo "Start PostgreSQL"
    ./pg_ctl -D ../databases start
    sleep 2
  fi
  cd $CURR_PATH
  # Start MySQL
  if ! [[ $(systemctl status mysqld.service) == *"active (running)"* ]]
  then
    echo "Start MySQL Server"
    systemctl start mysqld.service
    sleep 2
  fi
  # Stop TinyBrace Server
  if pgrep -x "tbserver" > /dev/null
  then
    echo "Stop TinyBrace Server"
    pkill -9 tbserver
    sleep 2
  fi
  # Initialize data for TinyBrace Server
  $TINYBRACE_HOME/bin/tbeshell $TINYBRACE_HOME/databases/limit_orderby.db < ./tinybrace_multi.dat
  # Start TinyBrace Server
  echo "Start TinyBrace Server"
  cd $TINYBRACE_HOME
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TINYBRACE_HOME/lib
  bin/tbserver &
  sleep 3
fi

cd $CURR_PATH
rm /tmp/file_fdw_multi.csv
cp ./file_fdw_multi.csv /tmp/

# SET PASSWORD = PASSWORD('Mysql_1234')
mysql -uroot -pMysql_1234 < ./mysql_multi.dat

# postgres should be already started with port=15432
# pg_ctl -o "-p 15432" start -D data

$POSTGRES_HOME/bin/psql -p 15432 postgres -c "create user postgres with encrypted password 'postgres';"
$POSTGRES_HOME/bin/psql -p 15432 postgres -c "grant all privileges on database postgres to postgres;"
$POSTGRES_HOME/bin/psql -p 15432 postgres -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql -p 15432 postgres -c "GRANT ALL PRIVILEGES ON SCHEMA public TO postgres;"
$POSTGRES_HOME/bin/psql postgres -p 15432  -U postgres < ./postgres_multi.dat

# Setup InfluxDB
influx -import -path=./influx_multi.data -precision=ns
