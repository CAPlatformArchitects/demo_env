#!/bin/bash
#
# This script loads feature toggles directly in the demo database.
# With several demo servers, the actual data that drives the toggle values is
# pulled down from a central location.  This cleanly dissassociates the reset
# environment/scripts from the actual data.
#
# NOTE: All demo servers will enable 'early' toggles currently on Rally100
# NOTE: for audemo (demo05) we do not want 'early' toggles; this is handled below
#
# Date: 05/10/2012
# Last Updated: 10/13/2012
# Author: David Thomas, <dthomas@rallydev.com>

source $(dirname $0)/toggle_config.sh

# safety net to ensure shared config env is loaded
[[ -z "${LOCAL_CONFIG_DIR}" ]] && echo "Config env not set. See config_env.sh. Aborting..." && exit 1

echo "*********************************"
echo "** Configuring Feature Toggles **"
echo "*********************************"

# get latest config file; data avail as $CONFIGS. format: name|value
load_config "feature_toggles.config"

echo "Removing existing feature toggles from database:"
sqlplus -S ${ORACLE_USER_CONNECT} <<EOF
DELETE from FEATURE_TOGGLE;
COMMIT;
EOF

echo "Loading ${NUM_CONFIGS} feature toggles into database:"
# Every user in the demo environment needs to be associated with each preference.
for config in ${CONFIGS}; do
  toggle_name=$(echo "${config}" | awk -F\| '{print $1}')
  toggle_value=$(echo "${config}" | awk -F\| '{print $2}')
  toggle_subscription=$(echo "${config}" | awk -F\| '{print $3}')

  # error handling: skip incomplete configs; format: name|value|subscription
  if [ -z "${toggle_name}" -o -z "${toggle_value}" -o -z "${toggle_subscription}" ]; then
    echo "Warning: No toggle name, or value, or subscription found for config=[${config}]. Skipping..."
    continue
  fi;

  #----------------------------------------------------
  # skip Rally Only / Early Toggles for audemo (demo05)
  #----------------------------------------------------
  # FIXME: hardcoding demo05 as audemo; audemo may change to a diff host in future
  if [ "${HOSTNAME}" = "ec-demo-05" -a "${toggle_subscription}" = 100 ]; then
    echo "Info: Skipping Rally Only toggle '${toggle_name}' for audemo..."
    continue
  fi;

  echo -n "  > Creating Feature Toggle '${toggle_name}' => '${toggle_value}'... "
  sqlplus -S ${ORACLE_USER_CONNECT} <<EOF
  SET ECHO OFF
  SET FEEDBACK OFF
  SET HEADING OFF
  INSERT INTO FEATURE_TOGGLE (NAME,VALUE,OID,UUID,SUBSCRIPTION_ID,USER_OID) VALUES ('${toggle_name}',${toggle_value},OID_SEQ.NEXTVAL,HEXTORAW(GET_UUID()), -1,-1);
  COMMIT;
  exit;
EOF
  echo "Done"
done

echo "Finished."

exit 0
