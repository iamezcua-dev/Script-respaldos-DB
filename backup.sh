#!/bin/bash

# This script runs a Postgres backup of the Palantir database.
# It is somewhat hard-coded for PRODUCTION file paths,
# but it should be fairly easy to convert for STAGING.

# Currently this script is deployed on prod-db01 to /opt/palantir/backup/daily

#####################
### Configuration ###
#####################

# The number of files to retain going backward
RETAIN_BACKUPS=15

# Database name
DATABASE="prod_pgr"

# Target folder for writing files
FOLDER=/opt/palantir/backup/daily/files

##########################
### DONE CONFIGURATION ###
##########################

NOW=$(date +"%Y-%m-%d")
FILENAME="production-backup-$NOW.sql"
TARGET="$FOLDER/$FILENAME"
echo "[$(date)] Backing up PRODUCTION database to: $TARGET"

pg_dump --clean $DATABASE > $TARGET
echo "[$(date)] Backup complete. Compressing..."
cd $FOLDER; gzip $FILENAME

##
##TODO: add in code for copying backup to SFTP server
##


# Remove older files (so we don't eat up all of the disk)
n=1
cd $FOLDER
for f in `ls -t *.gz`; do
  n=$(( n + 1 ))
  if [ "$n" -gt "$RETAIN_BACKUPS" ]
    then
     echo "[$(date)] Erasing file: $f"
     rm -f "$FOLDER/$f"
  fi
done

echo "[$(date)] Done."
