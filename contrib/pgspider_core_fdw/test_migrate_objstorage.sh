#! /bin/sh
# script for objstorage testing

usage() { echo "Usage: $0 [optional -t <all>]" 1>&2; exit 1; }

while getopts ":t:" o; do
    case "${o}" in
        t)
            t=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

#Save original values regress, temp-install, checkprep before change
ORIGIN_REGRESS=$(grep 'REGRESS = \([^\n]\+\)' Makefile)
ORIGIN_TMP_INSTALL=$(grep 'temp-install: \([^\n]\+\)' Makefile)
ORIGIN_CHECKPREP=$(grep 'checkprep: \([^\n]\+\)' Makefile)

rm -rf make_check.out || true

if [[ "all" == $t ]]; then

    sed -i 's/REGRESS =.*/REGRESS =/' Makefile
    sed -i '/REGRESS =.*/ s/$/ migrate\/objstorage\/objstorage_fdw_migrate_csv_local migrate\/objstorage\/objstorage_fdw_migrate_csv_azure migrate\/objstorage\/objstorage_fdw_migrate_csv_gcs migrate\/objstorage\/objstorage_fdw_migrate_csv_s3/' Makefile
    sed -i '/REGRESS =.*/ s/$/ migrate\/objstorage\/objstorage_fdw_migrate_json_local migrate\/objstorage\/objstorage_fdw_migrate_json_azure migrate\/objstorage\/objstorage_fdw_migrate_json_gcs migrate\/objstorage\/objstorage_fdw_migrate_json_s3/' Makefile
    sed -i '/REGRESS =.*/ s/$/ migrate\/objstorage\/objstorage_fdw_migrate_orc_local migrate\/objstorage\/objstorage_fdw_migrate_orc_azure migrate\/objstorage\/objstorage_fdw_migrate_orc_gcs migrate\/objstorage\/objstorage_fdw_migrate_orc_s3/' Makefile
    sed -i '/REGRESS =.*/ s/$/ migrate\/objstorage\/objstorage_fdw_migrate_parquet_local migrate\/objstorage\/objstorage_fdw_migrate_parquet_azure migrate\/objstorage\/objstorage_fdw_migrate_parquet_gcs migrate\/objstorage\/objstorage_fdw_migrate_parquet_s3/' Makefile
    sed -i '/REGRESS =.*/ s/$/ migrate\/objstorage\/objstorage_fdw_migrate_tsv_local migrate\/objstorage\/objstorage_fdw_migrate_tsv_azure migrate\/objstorage\/objstorage_fdw_migrate_tsv_gcs migrate\/objstorage\/objstorage_fdw_migrate_tsv_s3/' Makefile
    sed -i '/REGRESS =.*/ s/$/ migrate\/objstorage\/objstorage_fdw_migrate_avro_local migrate\/objstorage\/objstorage_fdw_migrate_avro_azure migrate\/objstorage\/objstorage_fdw_migrate_avro_gcs migrate\/objstorage\/objstorage_fdw_migrate_avro_s3/' Makefile

else

    sed -i 's/REGRESS =.*/REGRESS = migrate\/objstorage\/objstorage_fdw_migrate_avro_local migrate\/objstorage\/objstorage_fdw_migrate_avro_azure migrate\/objstorage\/objstorage_fdw_migrate_avro_gcs migrate\/objstorage\/objstorage_fdw_migrate_avro_s3 /' Makefile

fi

sed -i 's/temp-install:.*/temp-install: EXTRA_INSTALL=contrib\/objstorage_fdw contrib\/pgspider_keepalive /' Makefile
sed -i 's/checkprep:.*/checkprep: EXTRA_INSTALL+=contrib\/pgspider_core_fdw contrib\/objstorage_fdw contrib\/pgspider_keepalive /' Makefile


cd init/migrate
./setup_migrate_objstorage.sh
if [ $? -ne 0 ]; then
    echo "init data failed."
    exit 2
fi

cd ../..

make clean
make
rm -rf results/migrate/objstorage || true
mkdir -p results/migrate/objstorage
make check | tee make_check.out

#Revert Makefile to original
ORIGIN_REGRESS=$(echo "${ORIGIN_REGRESS}" | sed -e 's/\//\\\//g')
ORIGIN_TMP_INSTALL=$(echo "${ORIGIN_TMP_INSTALL}" | sed -e 's/\//\\\//g')
ORIGIN_CHECKPREP=$(echo "${ORIGIN_CHECKPREP}" | sed -e 's/\//\\\//g')
sed -i -e "s/REGRESS =.*/${ORIGIN_REGRESS}/" Makefile
sed -i -e "s/temp-install:.*/${ORIGIN_TMP_INSTALL}/" Makefile
sed -i -e "s/checkprep:.*/${ORIGIN_CHECKPREP}/" Makefile
