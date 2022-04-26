# Setup MySQL
if [[ "--start" == $1 ]]
then
  # Start MySQL
  if ! [[ $(systemctl status mysqld.service) == *"active (running)"* ]]
  then
    echo "Start MySQL Server"
    systemctl start mysqld.service
    sleep 2
  fi
fi

# SET PASSWORD = PASSWORD('Mysql_1234')
mysql -uroot -pMysql_1234 < ./mysql_join_limit.dat