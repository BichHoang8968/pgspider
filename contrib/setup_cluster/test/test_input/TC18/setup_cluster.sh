 export SPD_SETUP_CONF_DIR=./
 rm node_information.json
 mv node_information_wrongport.json node_information.json
./setup_cluster -d $TEST_INPUT_PATH/TC18