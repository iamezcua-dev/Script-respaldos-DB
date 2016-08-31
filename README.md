This script runs a PostgreSQL backup of the Palantir database. It is somewhat hard-coded for PRODUCTION file paths, but it should be fairly easy to convert for STAGING.

This code, also sends automatically a copy of the backup to another server via sftp.

Currently this script is deployed on prod-db01 to /opt/palantir/backup/daily/
