#!/bin/bash
#
# Script to create a deployable archive for running the demo env locally

source $(dirname $0)/../config

BIN_DIR=$(dirname $0)
VERSION=$(date +%Y%m%d)
BUILD_VERSION=$(readlink $BIN_DIR/../oradump/import.dmp | cut -d '-' -f2 | cut -d '.' -f1)
CURRENT_ORADUMP=$(readlink ${BIN_DIR}/../oradump/import.dmp)  # fixme: make relative dir to allow running from any dir

ENTRIES="config README.localenv bin/ cache/ scripts/ tmp/ oradump/import.dmp oradump/${CURRENT_ORADUMP}"
ARCHIVE_NAME=demoenv-${VERSION}.${BUILD_VERSION}
ARCHIVE_ROOT_DIR=${BIN_DIR}/..
ARCHIVES_DIR=${BIN_DIR}/../archives

echo -n "Creating ${ARCHIVE_NAME}.tgz..."
# creates compressed archive with leading subdirectory as same name
tar --transform="s@^@${ARCHIVE_NAME}/@" \
    --transform="s@README.localenv@README@" \
    --exclude=".gitignore" \
    --exclude="*.swp" \
    --exclude="archive.sh" --exclude="update.sh" --exclude="bin/toggles" \
    --create \
    --gzip \
    --verbose \
    --directory=${ARCHIVE_ROOT_DIR} \
    --file ${ARCHIVES_DIR}/${ARCHIVE_NAME}.tgz \
    ${ENTRIES} > /dev/null 2>&1

echo "Finished."

echo "Archive: ${ARCHIVES_DIR}/${ARCHIVE_NAME}.tgz"

exit 0
