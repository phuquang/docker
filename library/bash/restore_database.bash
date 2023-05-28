#!/bin/bash

USER="root"
PASSWORD=""
OUTPUT="/backups/mysql/20230528"

for SQL in $OUTPUT/*.sql.gz; do
    DB=${SQL/\/backups\/mysql\/20230528\//}
    DB=${DB/\.sql\.gz/}
    echo "Importing $DB ..."
    mysql --defaults-extra-file=<(echo $'[client]\npassword='"$PASSWORD") -u $USER -e "CREATE DATABASE \`$DB\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    zcat $SQL | mysql --defaults-extra-file=<(echo $'[client]\npassword='"$PASSWORD") -u $USER $DB
done
