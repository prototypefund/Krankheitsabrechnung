-- =============================================
-- GNUmed - static tables for unmatched incoming data
-- =============================================
-- $Source: /home/ncq/Projekte/cvs2git/vcs-mirror/gnumed/gnumed/server/sql/gmUnmatchedData-static.sql,v $
-- $Id: gmUnmatchedData-static.sql,v 1.5 2006-01-06 10:12:02 ncq Exp $
-- license: GPL v2 or later
-- author: Karsten.Hilbert@gmx.net

-- =============================================
-- force terminate + exit(3) on errors if non-interactive
\set ON_ERROR_STOP 1

-- ---------------------------------------------
create table clin.incoming_data_unmatched (
	pk serial primary key,
	fk_patient_candidates integer[],
	request_id text,
	firstnames text,
	lastnames text,
	dob date,
	postcode text,
	other_info text,
	type text,
	data bytea
		not null
) inherits (audit.audit_fields);

select audit.add_table_for_audit('clin', 'incoming_data_unmatched');

-- =============================================
select log_script_insertion('$RCSfile: gmUnmatchedData-static.sql,v $4', '$Revision: 1.5 $');

-- =============================================
-- $Log: gmUnmatchedData-static.sql,v $
-- Revision 1.5  2006-01-06 10:12:02  ncq
-- - add missing grants
-- - add_table_for_audit() now in "audit" schema
-- - demographics now in "dem" schema
-- - add view v_inds4vaccine
-- - move staff_role from clinical into demographics
-- - put add_coded_term() into "clin" schema
-- - put German things into "de_de" schema
--
-- Revision 1.4  2006/01/05 16:04:37  ncq
-- - move auditing to its own schema "audit"
--
-- Revision 1.3  2005/11/27 13:00:59  ncq
-- - since schema "clin" exists now we better use it
--
-- Revision 1.2  2005/11/01 08:53:50  ncq
-- - factor out re-runnables
--
-- Revision 1.1  2005/10/30 21:57:51  ncq
-- - incoming data tables: unmatched/unmatchable
--
--
