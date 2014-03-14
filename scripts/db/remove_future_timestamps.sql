
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

SELECT 'set autocommit on' FROM dual;

-- TODO: put extract/day syntax in string to make generated script idempotent
SELECT 'UPDATE ' || a.table_name || ' SET ' || a.column_name || ' =  sysdate - interval ''2'' day ' || ' WHERE ' || a.column_name || ' >= sysdate - interval ''1'' day' || ';'
  FROM user_tab_columns a
    JOIN user_tables b ON a.table_name = b.table_name
 WHERE a.data_type LIKE '%TIME%'                    -- match timestamp cols
   AND b.table_name != 'SUBSCRIPTION'               -- just because
   AND b.table_name != 'SLM_USER'                   -- prevent session errors with new users
   AND b.table_name != 'DEMO_DATESHIFT'             -- prevent bumping our own demo timestamping table
   AND b.table_name != 'ITERATION_CUM_FLOW'         -- don't mess with graphs
   AND b.table_name != 'RELEASE_CUM_FLOW'           -- don't mess with graphs
   AND b.table_name != 'DEFECT_PRIORITY_CUM_FLOW'   -- don't mess with graphs
   AND a.column_name NOT LIKE '%START_DATE'         -- don't change iteration/release start date
   AND a.column_name NOT LIKE '%END_DATE'           -- don't change iteration/release end date
   AND a.column_name NOT LIKE 'RELEASE_DATE'           -- don't change release end date
  -- prevent bumping our own demo timestamping table
 ORDER BY a.table_name;

SELECT 'commit;' FROM dual;
SELECT 'exit;' FROM dual;

spool off
exit
