#!/bin/sh
# start tbserver
if ! pgrep -x "tbserver" > /dev/null
then
  echo "Start TinyBrace Server"
  CURR_PATH=$(pwd)
  cd /usr/local/tinybrace
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/tinybrace/lib
  bin/tbserver &
  cd $CURR_PATH
  pwd
fi
sleep 3
# run setup script
cd init
./setup.sh
cd ..
make clean
make
make check | tee make_check.out
