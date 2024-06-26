#!/bin/sh

TMPDIR=/tmp/objstorage_fdw_migrate_test

rm -rf ${TMPDIR}
mkdir -p ${TMPDIR}

#Source 
docker compose -p objstoragetest stop minio
docker compose -p objstoragetest stop azurite
docker compose -p objstoragetest stop gcs
docker compose -p objstoragetest rm -fsv minio
docker compose -p objstoragetest rm -fsv azurite
docker compose -p objstoragetest rm -fsv gcs
docker volume rm objstoragetest_minio-data
docker volume rm objstoragetest_azurite-data
docker volume rm objstoragetest_gcs-data
docker compose -p objstoragetest up -d minio
docker compose -p objstoragetest up -d azurite
docker compose -p objstoragetest up -d gcs

#Destination
docker compose -p objstoragetest stop minio2
docker compose -p objstoragetest stop azurite2
docker compose -p objstoragetest stop gcs2
docker compose -p objstoragetest rm -fsv minio2
docker compose -p objstoragetest rm -fsv azurite2
docker compose -p objstoragetest rm -fsv gcs2
docker volume rm objstoragetest_minio-data2
docker volume rm objstoragetest_azurite-data2
docker volume rm objstoragetest_gcs-data2
docker compose -p objstoragetest up -d minio2
docker compose -p objstoragetest up -d azurite2
docker compose -p objstoragetest up -d gcs2

source scl_source enable gcc-toolset-11

g++ -LDFLAGS=-rdynamic \
 -lazure-storage-blobs -lazure-storage-common -lazure-core -lcurl -lssl -lcrypto -lpthread -lxml2 -lz -llzma -ldl \
 -labsl_base -labsl_throw_delegate -labsl_bad_any_cast_impl -labsl_bad_optional_access -labsl_bad_variant_access -lgoogle_cloud_cpp_common -lgoogle_cloud_cpp_storage \
 -laws-cpp-sdk-core -laws-cpp-sdk-s3 -lboost_iostreams \
 init_objstorage.cpp -o init_objstorage

./init_objstorage

rm init_objstorage
