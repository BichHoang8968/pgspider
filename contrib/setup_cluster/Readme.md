## setup_cluster tool

This tool setups a server configuration for PGSpider.


## Environment
Support only Linux.
But can build on Windows(not be tested).

## How to build
### On Linux (Centos 7):
1. Install Jansson library into the system folders.

```
sudo yum install jansson-devel
```

2. Build setup_cluster

```sh
make
```

### On Windows:
1. Put jansson files into "jansson" directory.
    * jansson/include/jansson.h
    * jansson/include/jansson_config.h
    * jansson/lib/jansson.lib
1. Put libpq files into "libpq" directory.  
    * libpq/include/libpq-fe.h
    * libpq/include/...
    * libpq/lib/libpq.lib
1. Put dirent files into "dirent" directory.  
You can clone from https://github.com/tronkko/dirent
1. Put getopt files into "winc" directory.  
You can clone from https://github.com/takamin/win-c
1. Build on GUI from setup_cluster.sln  

## Usage

setup_cluster [OPTION] [VALUE]

options:
* -d, configuration directory. The default directory is where setup_cluster binary file is located.
* -i, node information file name. The default name is 'node_information.json'.
* -s, node structure file name. The default name is 'node_structure.json'.
* -t, time interval allowed when connecting to pgspider database server. Default value is zero (0).
* -e, schema name. The default value is 'public'.
* -o, on conflict is 'none' or 'recreate'. The default value is 'none'. on conflict is applied to foreign server, user mapping and foreign table.
  * if on conflict is 'recreate', foreign server, user mapping, foreign table will be dropped and re-created. 
* -h, show this usage, then exit.
