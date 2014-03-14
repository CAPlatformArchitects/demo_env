#!/bin/bash
#
# This script manually enables/disables tooltip preferences directly in the database.
# The original request was to disable all tooltips as they are distracting in demo situations.
# With several demo servers, the actual data that drives the preference values is pulled down
# from a central location.  This cleanly dissassociates the reset environment/scripts from the actual data.
#
# Date: 05/09/2012
# Last Updated: 10/13/2012
# Author: David Thomas, <dthomas@rallydev.com>

source $(dirname $0)/toggle_config.sh

# safety net to ensure shared config env is loaded
[[ -z "${LOCAL_CONFIG_DIR}" ]] && echo "Config env not set. See config_env.sh. Aborting..." && exit 1

echo "*************************************"
echo "** Configuring Tooltip Preferences **"
echo "*************************************"

# get latest config file; data avail as $CONFIGS. format: name|value
load_config "tooltip_prefs.config"

echo "Loading ${NUM_CONFIGS} tooltip preferences into database:"
# Every user in the demo environment needs to be associated with each preference.
for config in ${CONFIGS}; do
  pref_name=${config%|*}     # name is before the pipe  {tooltip|value}
  pref_value=${config#*|}    # value is after the pipe  {tooltip|value}
  echo -n "  > Disabling tooltip '${pref_name}' => '${pref_value}'... "
  sqlplus -S ${ORACLE_USER_CONNECT} <<EOF
  SET ECHO OFF
  SET FEEDBACK OFF
  SET HEADING OFF
  -- start with a clean slate; some prefs may already exist in the baseline db
  DELETE FROM preference WHERE name = '${pref_name}';
  -- set pref value for all demo users
  -- Demo Subscription
  INSERT INTO preference (uuid, oid, subscription_id, version, creation_date, name, user_oid, workspace_oid, value, project_oid, panel_oid)
    SELECT HEXTORAW(GET_UUID()), oid_seq.nextval, 100, 1, sysdate, '${pref_name}', oid, null, '${pref_value}', null, null
      FROM slm_user;
  -- CE Demo Subscription
  INSERT INTO preference (uuid, oid, subscription_id, version, creation_date, name, user_oid, workspace_oid, value, project_oid, panel_oid)
    SELECT HEXTORAW(GET_UUID()), oid_seq.nextval, 232, 1, sysdate, '${pref_name}', oid, null, '${pref_value}', null, null
      FROM slm_user;

  COMMIT;
  exit;
EOF
  echo "Done"
done

echo "Finished."

exit 0
