#!/bin/bash
#
# Creates an export of the demo database.
#

TODAY_DATE=$(date +%Y%m%d)
BUILD_DATE=$(readlink ~/appserver-config-latest | sed -e 's/appserver-config-//g' -e 's/\///g')
DUMPFILE=proddb${TODAY_DATE}b${BUILD_DATE}.dmp
LOGFILE=${DUMPFILE}.log
DUMPFILE_DIR=~/reset_script/oradump
DB_DIRECTORY_NAME='DEMO_DUMP_DIR'

# note: the path is set in the database so this redirects the path based on who is running the export
sqlplus system/abc123@localhost/demo <<EOF
CREATE or REPLACE directory DEMO_DUMP_DIR as '${DUMPFILE_DIR}';
exit
EOF
echo "Set export dir to '${DUMPFILE_DIR}'"

cd $DUMPFILE_DIR

echo "Exporting database..."
expdp system/abc123@//localhost/demo \
      DIRECTORY=${DB_DIRECTORY_NAME} \
      DUMPFILE=${DUMPFILE} \
      LOGFILE=${LOGFILE} \
      METRICS=yes \
      SCHEMAS=demo,demo_analytics,demo_merge,demo_archive \
      CONTENT=ALL \
      JOB_NAME=demo_data_export

[[ $? -ne 0 ]] && exit 1

echo ""
echo "IMPORTANT: How to Save Export Dumpfiles to Git"
echo ""
echo "      The Oracle export tool forces dumpfile ownership to oracle user/group settings."
echo "      This will prevent committing the dumpfile to git as a developer with a local repo."
echo "      To fix permissions, either:"
echo ""
echo "      (A) $ sudo chmod 644 <dumpfile>             # per export; requires sudo"
echo "                                                  # allows any user to read the file and commit"
echo "      (B) $ chmod g+s ./reset_script/oradump      # one time; all dumpfiles share dir group setting"
echo "                                                  # allows any user in the directory -group- to access file"
echo ""
echo "   ** note that git does not support setgid bit so option (b) is one time *per* clone/checkout."

echo "Export finished."

cd -

exit 0
