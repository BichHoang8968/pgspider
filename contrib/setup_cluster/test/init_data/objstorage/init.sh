#!/bin/sh

TMPDIR=/tmp/objstorage_fdw_test

rm -rf ${TMPDIR}
mkdir -p ${TMPDIR}
mkdir -p ${TMPDIR}/local
cp -ra data ${TMPDIR}/local/

source scl_source enable devtoolset-11

make clean
make

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

./prepareTestStorage s3 data data "minioadmin" "minioadmin" "http://127.0.0.1:9000"
./prepareTestStorage azure data data devstoreaccount1 Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw== http://127.0.0.1:10000/devstoreaccount1
./prepareTestStorage gcs data data "http://127.0.0.1:4443"
