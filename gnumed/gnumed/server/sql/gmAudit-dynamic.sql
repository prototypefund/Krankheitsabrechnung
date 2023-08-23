-- GNUmed auditing functionality
-- ===================================================================
-- license: GPL v2 or later
-- author: Karsten Hilbert

-- ===================================================================
-- force terminate + exit(3) on errors if non-interactive
\set ON_ERROR_STOP 1

-- ===================================================================
-- schema
grant usage on schema audit to group "gm-doctors";

-- ===================================================================
comment on table audit.audited_tables is
	'All tables that need standard auditing must be
	 recorded in this table. Audit triggers will be
	 generated automatically for all tables recorded
	 here.';

comment on table audit.audit_fields is
	'this table holds all the fields needed for auditing';
comment on column audit.audit_fields.row_version is
	'the version of the row; mainly just a count';
comment on COLUMN audit.audit_fields.modified_when is
	'when has this row been committed (created/modified)';
comment on COLUMN audit.audit_fields.modified_by is
	'by whom has this row been committed (created/modified)';

comment on table audit.audit_trail is
	'Each table that needs standard auditing must have a log table inheriting
	 from this table. Log tables have the same name with a prepended "log_".
	 However, log_* tables shall not have constraints.';
comment on column audit.audit_trail.orig_version is
	'the version of this row in the original table previous to the modification';
comment on column audit.audit_trail.orig_when is
	'previous modification date in the original table';
comment on column audit.audit_trail.orig_by is
	'who committed the row to the original table';
comment on column audit.audit_trail.orig_tableoid is
	'the table oid of the original table, use this to identify the source table';
comment on column audit.audit_trail.audit_action is
	'either "update" or "delete"';
comment on column audit.audit_trail.audit_when is
	'when committed to this table for auditing';
comment on column audit.audit_trail.audit_by is
	'committed to this table for auditing by whom';

-- ===================================================================
create or replace function audit.add_table_for_audit(name, name)
	returns boolean
	language 'plpgsql'
	security definer
	as '
DECLARE
	_relnamespace alias for $1;
	_relname ALIAS FOR $2;
	dummy RECORD;
	tmp text;
BEGIN
	-- does table exist ?
	select relname into dummy from pg_class where
		relname = _relname and
		relnamespace = (select oid from pg_namespace where nspname = _relnamespace)
	;
	if not found then
		tmp := _relnamespace || ''.'' || _relname;
		raise exception ''audit.add_table_for_audit: Table [%] does not exist.'', tmp;
		return false;
	end if;
	-- already queued for auditing ?
	select 1 into dummy from audit.audited_tables where table_name = _relname and schema = _relnamespace;
	if found then
		return true;
	end if;
	-- add definition
	insert into audit.audited_tables (
		schema, table_name
	) values (
		_relnamespace, _relname
	);
	return true;
END;';

comment on function audit.add_table_for_audit (name, name) is
	'sanity-checking convenience function for marking tables for auditing';


create or replace function audit.add_table_for_audit(name)
	returns boolean
	language SQL
	security definer
	as '
select audit.add_table_for_audit(''public'', $1);';

comment on function audit.add_table_for_audit(name) is
	'sanity-checking convenience function for marking tables
	 for auditing, schema is always "public"';

-- ---------------------------------------------
-- protect from direct inserts/updates/deletes which the
-- inheritance system can't handle properly
\unset ON_ERROR_STOP
drop rule audit_fields_no_ins on audit.audit_fields cascade;
drop rule audit_fields_no_upd on audit.audit_fields cascade;
drop rule audit_fields_no_del on audit.audit_fields cascade;
\set ON_ERROR_STOP 1

-- FIXME: those should actually use PL/pgSQL and raise
--        an exception...
create rule audit_fields_no_ins as
	on insert to audit.audit_fields
	do instead nothing;

create rule audit_fields_no_upd as
	on update to audit.audit_fields
	do instead nothing;

create rule audit_fields_no_del as
	on delete to audit.audit_fields
	do instead nothing;

-- ---------------------------------------------
-- protect from direct inserts/updates/deletes which the
-- inheritance system can't handle properly
\unset ON_ERROR_STOP
drop rule audit_trail_no_ins on audit.audit_trail cascade;
drop rule audit_trail_no_upd on audit.audit_trail cascade;
drop rule audit_trail_no_del on audit.audit_trail cascade;
\set ON_ERROR_STOP 1

-- FIXME: those should actually use PL/pgSQL and raise
--        an exception...
create rule audit_trail_no_ins as
	on insert to audit.audit_trail
	do instead nothing;

create rule audit_trail_no_upd as
	on update to audit.audit_trail
	do instead nothing;

create rule audit_trail_no_del as
	on delete to audit.audit_trail
	do instead nothing;

-- ===================================================================
grant SELECT on
	audit.audit_trail
	, audit.audit_trail_pk_audit_seq
to group "gm-doctors";

grant SELECT, insert, update, delete on
	audit.audit_fields
	, audit.audit_fields_pk_audit_seq
to group "gm-doctors";

-- ===================================================================
-- do simple schema revision tracking
-- keep the "true" !
delete from gm_schema_revision where filename = '$RCSfile: gmAudit-dynamic.sql,v $';
insert into gm_schema_revision (filename, version) values ('$RCSfile: gmAudit-dynamic.sql,v $', '$Revision: 1.8 $');

-- ===================================================================
