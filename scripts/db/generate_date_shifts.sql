
--
-- SQL script to generate SQL that updates all timestamp columns by number of given days
--

set heading off
set echo off
set pagesize 0
set wrap off
set feedback off
set timing off
set linesize 500
-- disable showing replaced values
set verify off

DEFINE OUTPUT_SQL_FILE = &1

spool &OUTPUT_SQL_FILE

SELECT '-- THIS FILE IS AUTO-GENERATED -- DO NOT EDIT DIRECTLY' FROM dual;
SELECT '-- Generated on: ' || sysdate FROM dual;

SELECT 'set autocommit on' FROM dual;

-- FIXME: put this in the oradump
--drop table DEMO_DATESHIFT;
--create table DEMO_DATESHIFT (effective_now timestamp);
--insert into DEMO_DATESHIFT (select max(creation_date) from artifact);
--commit;

SELECT '-- ** SHIFTING DATE: ' || (EXTRACT(DAY FROM sysdate - effective_now) ) || ' DAYS' from DEMO_DATESHIFT where ROWNUM = 1;

-- TODO: put extract/day syntax in string to make generated script idempotent
SELECT 'UPDATE ' || a.table_name || ' SET ' || a.column_name || ' = ' || 'dst_adjust(' || a.column_name || ', ' || a.column_name || ' + interval ''1'' day + ' || 'interval ''' || (SELECT (EXTRACT(DAY FROM sysdate - effective_now) ) from DEMO_DATESHIFT where ROWNUM = 1) || ''' day' || ');'
  FROM user_tab_columns a
    JOIN user_tables b ON a.table_name = b.table_name
 WHERE a.data_type LIKE '%TIME%'
   AND b.table_name != 'SLM_USER'      -- prevent session errors with new users
   AND b.table_name != 'DEMO_DATESHIFT'             -- prevent bumping our own demo timestamping table
 ORDER BY a.table_name;

SELECT 'UPDATE demo_dateshift SET effective_now = sysdate;' FROM dual;

SELECT 'commit;' FROM dual;
SELECT 'exit;' FROM dual;

spool off
exit
