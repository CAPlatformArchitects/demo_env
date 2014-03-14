#!/bin/bash -e

# Retrieve latest demo data file

# TODO: bring down fully qualified oradump name

FILENAME=import.dmp
DUMPFILE=http://bld-demoenv-01.f4tech.com/${FILENAME}
LOCALFILE=/root/demo_env/oradump/${FILENAME}

wget -q ${DUMPFILE} --output-document=${LOCALFILE}
