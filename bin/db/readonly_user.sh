
source $(dirname $0)/../../config
sqlplus ${ORACLE_SYSTEM_CONNECT} <<EOF

DROP USER DEMO_READONLY;
CREATE USER DEMO_READONLY
  IDENTIFIED BY DEMO_READONLY
  DEFAULT TABLESPACE DEMO_DATA
  TEMPORARY TABLESPACE TEMP
  PROFILE DEFAULT
  ACCOUNT UNLOCK;
  -- 1 Role for DEMO_READONLY 
  GRANT DEMO_READROLE TO DEMO_READONLY;
  ALTER USER DEMO_READONLY DEFAULT ROLE ALL;
  -- 1 System Privilege for DEMO_READONLY 
  GRANT CREATE SESSION TO DEMO_READONLY;
exit;
EOF