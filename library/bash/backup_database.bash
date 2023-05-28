#!/bin/bash
# Author: PhuQuang
#
USER="pauli"
PASSWORD=""
OUTPUT="/backups/mysql"

mkdir -p $OUTPUT/`date +%Y%m%d`

echo "Backups are stored in the directory:" $OUTPUT/`date +%Y%m%d`

#rm "$OUTPUTDIR/*gz" > /dev/null 2>&1

databases=`mysql --defaults-extra-file=<(echo $'[client]\npassword='"$PASSWORD") -u $USER -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != "sys" ]] && [[ "$db" != _* ]] ; then
        echo "Dumping database: $db"
        mysqldump --defaults-extra-file=<(echo $'[client]\npassword='"$PASSWORD") -u $USER --databases $db | gzip > $OUTPUT/`date +%Y%m%d`/$db.sql.gz
    fi
done

echo "Check directory: " $OUTPUT/`date +%Y%m%d`
echo "Backup is done."
