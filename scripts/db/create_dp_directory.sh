#!/bin/bash -e

#
# Create location of oradump file used by impdmp for importing demo data
#

source $(dirname $0)/../../config

sqlplus ${ORACLE_SYSTEM_CONNECT} << SQL

CREATE OR REPLACE DIRECTORY demo_dump_dir AS '/root/demo_env/oradump';

SQL
