#
# Description: This shell script will facilitate a full export of an Oracle Database

source $(dirname $0)/../../config

# read/only user role
./$(dirname $0)/readrole_grant.sh
./$(dirname $0)/readonly_user.sh

sqlplus ${ORACLE_SYSTEM_CONNECT} <<EOF
drop user ${ORACLE_USER_ID} cascade;
drop user ${ORACLE_USER_ID}_ANALYTICS cascade;
drop user ${ORACLE_USER_ID}_ARCHIVE cascade;
drop user ${ORACLE_USER_ID}_MERGE cascade;
exit;
EOF

# TODO: auto symlink manage to latest dumpfile?
DUMPFILE=import.dmp

# import dataset
# - note: DIRECTORY location (set in db) specifies where dumpfile is loaded from and logs written
impdp ${ORACLE_SYSTEM_CONNECT} \
  DIRECTORY=demo_dump_dir \
  LOGFILE=${DUMPFILE}.log \
  DUMPFILE=${DUMPFILE} \
  CONTENT=ALL \
  JOB_NAME=demo_data_import \
  EXCLUDE=INDEX_STATISTICS

exit 0
