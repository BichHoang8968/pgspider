#!/bin/bash
# Script to set up PGSpider cluster
#
PGSPIDER_SETUPCLUSTER=$1

setup_pgspider_cluster(){
  cd $PGSPIDER_SETUPCLUSTER
  make clean > /dev/null && make > /dev/null
  echo "--------- EXECUTE SETUP CLUSTER ---------"
  $PGSPIDER_SETUPCLUSTER/setup_cluster
  
}

setup_pgspider_cluster