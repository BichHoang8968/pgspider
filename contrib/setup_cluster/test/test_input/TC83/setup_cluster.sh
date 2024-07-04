PGS1_DB=databases

export LD_PRELOAD=/lib64/libstdc++.so.6
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH$SLDCS_LIB_PATH

CUR_PATH=$(pwd)
cd ${PGS1_DIR}/bin
./pg_ctl -D ../${PGS1_DB} restart > /dev/null 2>&1

cd $CUR_PATH
./setup_cluster