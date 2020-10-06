create or replace PROCEDURE x_TO_OS (p_ID IN x_ATTACHMENTS.ID%TYPE) AS
v_blob BLOB;
v_start NUMBER := 1;
v_bytelen NUMBER := 32000;
v_len NUMBER ;
v_len_copy NUMBER;
v_filename varchar2(160);

v_raw_var RAW(32000);
v_output utl_file.file_type;
BEGIN
v_start := 1;
v_bytelen := 32000;

-- get length of blob
SELECT DBMS_LOB.GETLENGTH(FILE_BLOB)
INTO v_len
FROM x_ATTACHMENTS     --table name to use
where ID = p_ID  ;

-- save blob length
v_len_copy := v_len;
-- Get the blob
select FILE_BLOB,filename
into v_blob,v_filename
FROM x_ATTACHMENTS
where ID = p_ID and  file_mimetype like 'image%' ;

-- define output directory and open the file in write byte mode
v_output := utl_file.fopen('TGT_FILES', 'WO'||p_id||'%'||v_filename,'wb', 32000);  --TGT_FILES = oracle directory  --WO=Value for case statement in img.sh
-- Maximum size of buffer parameter is 32767 before which you have to flush your buffer

IF v_len < 32000 THEN
utl_file.put_raw(v_output,v_blob);
utl_file.fflush(v_output);
ELSE -- write in separate buffers
v_start := 1;
WHILE v_start < v_len and v_bytelen > 0
LOOP
DBMS_LOB.READ(v_blob,v_bytelen,v_start,v_raw_var);
utl_file.put_raw(v_output,v_raw_var);
utl_file.fflush(v_output);

-- set the start position for next flush
v_start := v_start + v_bytelen;

-- set the end position if less than 32000 bytes
v_len_copy := v_len_copy - v_bytelen;
IF v_len_copy < 32000 THEN
v_bytelen := v_len_copy;
END IF;
dbms_output.put_line('fileuploaded'||p_id);
end loop;
utl_file.fclose(v_output);
END IF;

END;

