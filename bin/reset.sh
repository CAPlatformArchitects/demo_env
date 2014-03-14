#!/bin/bash
#
# Full reset of the demo environment in Rally
#
# NOTE: Requires /etc/init.d/rallyapp in place (see ../scripts/init.d)
source ~/.bashrc
source ~/.bash_profile
source $(dirname $0)/../config

cd $(dirname $0)

# Stop Rally
./stop.sh
# Create fresh DB & Import data set
./db/reset_database.sh
${RALLY_HOME_LATEST}/migration/migrations.rb -c
# Date shift all data
./db/date_shift.sh
# Feature toggles and tooltips
./toggles/config_tooltips.sh
./toggles/config_feature_toggles.sh

# Start Rally
./start.sh

${RALLY_HOME_LATEST}/migration/migrations.rb --poststartup

exit 0
