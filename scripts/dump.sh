#!/bin/bash

TEMPORARY_PATH1=~/database/warehouse.dump.original
TEMPORARY_PATH2=~/database/warehouse.dump
DUMP_PATH=~/database/warehouse-dump/warehouse.dump.gz
SED_SCRIPT=~/code/warehouse/secret/warehouse.sed

while [ 1 ]
do
	pg_dump -f $TEMPORARY_PATH1 -t scene_access_data -t torrentvault_data -t torrentleech_data warehouse
	sed -f $SED_SCRIPT < $TEMPORARY_PATH1 > $TEMPORARY_PATH2
	rm $TEMPORARY_PATH1
	gzip -1 -f $TEMPORARY_PATH2
	mv $TEMPORARY_PATH2.gz $DUMP_PATH
	sleep 1800
done

