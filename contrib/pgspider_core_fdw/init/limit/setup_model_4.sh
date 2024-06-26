source $(pwd)/../environment_variable.config

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

# Start docker
griddb_image=$GRIDDB_IMAGE
griddb_container_name=griddb_svr
clean_docker_img ${griddb_container_name}
docker run -d --name ${griddb_container_name} -p 10001:10001 -e GRIDDB_NODE_NUM=1 ${griddb_image}

cd $CURR_PATH
# Initialize data for GridDB
echo "Init data for GridDB for model 4..."
rm /tmp/griddb_single.data
cp -a griddb_single.data /tmp/
gcc griddb_init.c -o griddb_init -I${GRIDDB_CLIENT}/client/c/include -L${GRIDDB_CLIENT}/bin -lgridstore
./griddb_init 127.0.0.1:10001 dockerGridDB admin admin /tmp/griddb_single.data