#!/bin/bash

source $(dirname $0)/../../config

# Generate SQL to shift dates
GENERATE_SQL_FILE="../scripts/db/generate_date_shifts.sql"
DATE_SHIFT_SQL_FILE="../tmp/date_shift.sql"
DST_ADJUST_SQL_FILE="../scripts/db/dst.sql"

# Generate dynamic sql to update all timestamp table/columns
sqlplus ${ORACLE_USER_CONNECT} @${GENERATE_SQL_FILE} ${DATE_SHIFT_SQL_FILE}

# Function for adjusting DST
sqlplus ${ORACLE_USER_CONNECT} @${DST_ADJUST_SQL_FILE}

# Execute SQL to shift dates
sqlplus ${ORACLE_USER_CONNECT} @${DATE_SHIFT_SQL_FILE}

exit 0
