Demo Environment
==

Utilities for loading and resetting Rally Demo Environments.
# README.txt
#
# This file describes the reset scripts and data refresh process.

# ----------
# QUICKSTART
# ----------
# To reset the environment, simply run:
#
#      ./bin/reset.sh
#
# This script will fetch a new build if available, drop & restoree the
# database, start the Rally service, and perform any data transforms
# as needed.  After a reset completes, the URL of the server will serve
# up this instance of Rally.

# Files/Directories 
> bin                     - entry point; scripts to start, stop, restart, etc
  - reset.sh                - primary script to entirely reset env
  - stop.sh                 - helper script to STOP Rally
  - start.sh                - helper script to START Rally
  - restart.sh              - helper script to RESTART Rally
  - update.sh               - helper script to fetch new build/release
  - export.sh               - create new copy of database in oradump format
  > toggles                 - scripts to set/reset feature toggles and prefs
> scripts                 - utility script for loading or transforming data
  - db/*                    - database sql & scripts to transform data
  - init.d/                 - start/stop scripts
> oradump                 - data set files to load
> cache/                    - temp location for data & configs fetched during reset
> import/                   - data import scripts (typically run once before exporting new db)
> tmp/                      - temp dir for files created/used during reset process (e.g. generated sql)
> TODO.txt                - stuff to remember todo
> README.txt              - this file

# ---------
# LOG FILES
# ---------
# For startup problems, monitor: ~/domains/alm/logs/startup.log
README

This demoenv package provides all the necessary scripts and data
for loading a local instance of Rally with demo data.

REQUIREMENTS

1. Linux environment
2. Compatible or *latest* copy of Rally (appserver-config-master-####)
3. Local instance of Oracle and import/export datapump utilities (impdp/expdp)

INSTRUCTIONS

1. Edit config        # or copy from prior installation
2. Run reset script   # est. ~5min
  $ ./bin/reset.sh
3. Login to Rally     # any demo user account

NOTES

* The demoenv archive contains the Rally build number used
  at the time of creating the oracle data file.  The local
  version of Rally must be equal or greater.  Because the
  reset process runs migrations during the import, you can
  have a newer Rally build with an older demo env / database file.

      Format: demoenv-<CreateDate>.<RallyBuild#>.tgz

TROUBLESHOOTING

Problem: Unable to connect to database.
Solution: Confirm ORACLE_SID, ORACLE_HOME, ORACLE_HOSTNAME,
          and ORACLE_USER/SYSTEM vars are set and valid in ./config

Problem: Database import complains that ALL objects already exist.
Solution: Importing the db requires no active connections.  Be sure Rally
          is stopped (no java processes) by running ./bin/stop.sh

