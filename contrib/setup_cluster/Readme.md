# setup_cluster tool

This tool setups a server configuration for PGSpider.


## Environment
Support only Linux.
But can build on Windows(not be tested).

## How to build
### On Linux:
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


