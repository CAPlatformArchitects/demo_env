set serveroutput off

-- Rules for detecting Daylight Savings Time change
-- *  begins 2am on second Sunday of March
-- *  ends 2am on first Sunday of November

CREATE or REPLACE
FUNCTION dst_adjust(p_timestamp_orig IN timestamp, p_timestamp_shifted IN timestamp) RETURN timestamp IS
  dst_end timestamp(6);
  dst_start timestamp(6);
BEGIN

  -- some columns have no date value set
  IF p_timestamp_orig IS NULL THEN
    RETURN p_timestamp_orig;
  END IF;

  -- date/time when dst starts; hardcoding +6hrs for assumption that all demo workspaces are MT
  SELECT next_day(to_date('01-MAR-'||to_char(p_timestamp_orig,'YYYY'),'DD-MON-YYYY' ) -1, 'SUNDAY') + 7 + 6/24
    INTO dst_start
    FROM dual;

  -- date/time when dst ends; hardcoding +6hrs for assumption that all demo workspaces are MT
  SELECT next_day(to_date('01-NOV-'||to_char(p_timestamp_orig,'YYYY'),'DD-MON-YYYY' ) -1, 'SUNDAY') + 6/24
    INTO dst_end
    FROM dual;

  dbms_output.put_line('--');
  dbms_output.put_line('DST START/END: ' || dst_start || ' / ' || dst_end);
  dbms_output.put_line('TIMESTAMP / SHIFT: ' || p_timestamp_orig || ' / ' || p_timestamp_shifted);
  dbms_output.put_line('SHIFT DAYS: ' || (p_timestamp_shifted - p_timestamp_orig));

  -- Exiting DST
  IF p_timestamp_orig >= dst_start AND p_timestamp_orig < dst_end AND p_timestamp_shifted >= dst_end THEN
    dbms_output.put_line('Exiting DST');
    RETURN p_timestamp_shifted - interval '1' hour;
  -- Entering DST
  ELSIF p_timestamp_orig < dst_start AND p_timestamp_shifted >= dst_start AND p_timestamp_shifted < dst_end THEN
    dbms_output.put_line('Entering DST');
    RETURN p_timestamp_shifted + interval '1' hour;
  END IF;

  dbms_output.put_line('No DST Boundary Change');

  RETURN p_timestamp_shifted;

END;
/

exit;
