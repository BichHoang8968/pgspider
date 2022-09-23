#!/bin/sh
export MONGO_HOST="localhost"
export MONGO_PORT="27017"
export MONGO_USER_NAME="edb"
export MONGO_PWD="edb"

# Below commands must be run in MongoDB to create setup_cluster
# used in regression tests with edb user and edb password.

# use setup_cluster
# db.createUser({user:"edb",pwd:"edb",roles:[{role:"dbOwner", db:"setup_cluster"},{role:"readWrite", db:"setup_cluster"}]})

mongo --host=$MONGO_HOST --port=$MONGO_PORT -u $MONGO_USER_NAME -p $MONGO_PWD --authenticationDatabase "setup_cluster" < init_mongo.js > /dev/null
