#!/bin/bash
# This script runs a Postgres backup of the Palantir database.
# It is somewhat hard-coded for PRODUCTION file paths,
# but it should be fairly easy to convert for STAGING.
# Currently this script is deployed on prod-db01 to /opt/palantir/backup/daily
#####################
### Configuration ###
#####################
# The number of files to retain going backward
RETAIN_BACKUPS=3
# Database name
DATABASE="prod_pgr"
# Target folder for writing files
FOLDER=/opt/palantir/backup/daily/files
##########################
### DONE CONFIGURATION ###
##########################

# Remove older files (so we don't eat up all of the disk)
n=0
cd $FOLDER
for f in `ls -t *.gz`; do
  n=$(( n + 1 ))
  if [ "$n" -gt "$RETAIN_BACKUPS" ]
    then
     echo "[$(date)] Erasing file: $f"
     rm -f "$FOLDER/$f"
  fi
done

# Create database backup
NOW=$(date +"%Y-%m-%d")
FILENAME="production-backup-$NOW.sql"
TARGET="$FOLDER/$FILENAME"
echo "[$(date)] Backing up PRODUCTION database to: $TARGET"
/opt/palantir/postgresql/bin/pg_dump --clean $DATABASE > $TARGET 2> backupProcess.err
echo "[$(date)] Backup complete. Compressing..."
gzip $TARGET

# Copying generated backup to Arturo's server via SFTP.
SFTPUSER=PalantirBackup
SERVER=10.3.248.19
PORT=2222
echo "[$(date)] Sending a copy of generated backup file towards Arturo's Server..."
sftp -oPort=$PORT $SFTPUSER@$SERVER << sFtpTask
        cd RESPALDOS
        put $TARGET.gz
        quit
sFtpTask

echo "[INF] Backup file copy process finished."
echo "[$(date)] Done."
