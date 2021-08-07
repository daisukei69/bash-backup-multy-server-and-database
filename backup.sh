#!/bin/bash

# File server format json
FILE_SERVER = <file json>

# read FILE_SERVER use jq https://stedolan.github.io/jq/
READ_SERVER="$(jq 'keys[]' $FILE_SERVER)"


for item in $READ_SERVER
do
	#Get time 
	CURRDATE=$(date '+%F_jam_%H:%M')
	
	FILEBACKUP="${DEST}/_$CURRDATE.sql"
	Get_host="$(jq ".$item.host" --raw-output $FILE_SERVER)"
	Get_user="$(jq ".$item.user" --raw-output $FILE_SERVER)"
	Get_pass="$(jq ".$item.pass" --raw-output $FILE_SERVER)"
	Get_db="$(jq ".$item.db" --raw-output $FILE_SERVER)"
	Get_port="$(jq ".$item.port" --raw-output $FILE_SERVER)"
	
	#for folder destination file backup
	DEST=/mnt/backup/${Get_db}
	
	FILEBACKUP="${DEST}/${Get_db}_$CURRDATE.sql"
	
	FILEBACKUP_STRUCTURE="${DEST}/${Get_db}_$CURRDATE_STRUCTURE_ONLY.sql"
	
	FILEBACKUP_DATA="${DEST}/${Get_db}_$CURRDATE_DATA_ONLY.sql"
		
	#if empty folder destination then create folder destination
	if [ ! -d "$DEST" ]; then
	mkdir $DEST
	fi
	
	#backup Data Base use mysqldump
	mysqldump --lock-tables=false --single-transaction -u$Get_user -h$Get_host -p$Get_pass -P$Get_port $Get_db > $FILEBACKUP
	
	#backup Data Only use mysqldump
	mysqldump --lock-tables=false --single-transaction -u$Get_user -h$Get_host -p$Get_pass -P$Get_port --no-create-info $Get_db > $FILEBACKUP_DATA
	
	#backup Data Only use mysqldump
	mysqldump --lock-tables=false --single-transaction -u$Get_user -h$Get_host -p$Get_pass -P$Get_port --no-data $Get_db > $FILEBACKUP_STRUCTURE
	
	#archive file sql to tar.xz
	tar -cjf ${DEST}/${Get_db}_$CURRDATE.tar.xz --absolute-names --directory=${DEST}/ ${Get_db}_$CURRDATE.sql
	
	#remove file sql
	rm ${DEST}/${Get_db}_$CURRDATE.sql

done
