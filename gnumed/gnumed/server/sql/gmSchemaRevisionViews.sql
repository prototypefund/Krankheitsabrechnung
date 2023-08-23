-- =============================================
-- project: GNUmed
-- license: GPL v2 or later
-- author: Karsten.Hilbert@gmx.net

-- =============================================
-- import this file into any database you create and
-- add the revision of your schema files into the revision table,
-- this will allow for a simplistic manual database schema revision control,
-- that may come in handy when debugging live production databases,

-- for your convenience, just copy/paste the following lines:
-- (don't worry about the filename/revision that's in there, it will
--  be replaced automagically with the proper data by "cvs commit")

-- do simple schema revision tracking
-- select log_script_insertion('$RCSfile: gmSchemaRevisionViews.sql,v $', '$Revision: 1.6 $');

-- =============================================
-- force terminate + exit(3) on errors if non-interactive
\set ON_ERROR_STOP 1

-- ---------------------------------------------
create or replace function gm_concat_table_structure()
	returns text
	language 'plpgsql'
	security definer
	as '
declare
	_row record;
	_total text;
begin
	_total := '''';
	-- schema.table.column.data_type
	for _row in
		select * from information_schema.columns cols
			where cols.table_name in (
				select tabs.table_name from information_schema.tables tabs where
					tabs.table_schema in (''public'', ''dem'', ''clin'', ''blobs'') and
					tabs.table_type = ''BASE TABLE''
				)
			order by
				md5(cols.table_schema || cols.table_name || cols.column_name || cols.data_type)
	loop
		_total := _total
			|| _row.table_schema || ''.''
			|| _row.table_name || ''.''
			|| _row.column_name || ''::''
			|| _row.udt_name || E''\n'';
	end loop;
	return _total;
end;
';

-- ---------------------------------------------
create or replace function log_script_insertion(text, text) returns text as '
declare
	_filename alias for $1;
	_version alias for $2;
	_hash text;
begin
	delete from gm_schema_revision where filename = _filename;
	insert into gm_schema_revision (filename, version) values (
		_filename,
		_version
	);
	select into _hash md5(gm_concat_table_structure());
	delete from gm_database_revision;
	insert into gm_database_revision (identity_hash) values (_hash);
	return _hash;
end;' language 'plpgsql';

-- =============================================
GRANT SELECT on
	gm_schema_revision
	, gm_database_revision
	, gm_client_db_match
TO group "gm-public";

-- =============================================
