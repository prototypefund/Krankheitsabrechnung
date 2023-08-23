-- =============================================
-- GNUmed - dynamic tables for unmatched incoming data
-- =============================================
-- $Source: /home/ncq/Projekte/cvs2git/vcs-mirror/gnumed/gnumed/server/sql/gmUnmatchedData-dynamic.sql,v $
-- $Id: gmUnmatchedData-dynamic.sql,v 1.2 2005-11-27 13:00:59 ncq Exp $
-- license: GPL v2 or later
-- author: Karsten.Hilbert@gmx.net

-- =============================================
-- force terminate + exit(3) on errors if non-interactive
\set ON_ERROR_STOP 1

-- ---------------------------------------------
comment on table clin.incoming_data_unmatched is
	'this table holds incoming data (lab results, documents)
	 that could not be matched to one single patient automatically,
	 it is intended to facilitate manual matching,
	 - use "modified_when" for import time';
comment on column clin.incoming_data_unmatched.fk_patient_candidates is
	'a matching algorithm can be applied to produce
	 a list of likely candidate patients, the question
	 remains whether this should not be done at runtime';
comment on column clin.incoming_data_unmatched.request_id is
	'request ID as found in <data>';
comment on column clin.incoming_data_unmatched.firstnames is
	'first names as found in <data>';
comment on column clin.incoming_data_unmatched.lastnames is
	'last names as found in <data>';
comment on column clin.incoming_data_unmatched.dob is
	'date of birth as found in <data>';
comment on column clin.incoming_data_unmatched.postcode is
	'postcode as found in <data>';
comment on column clin.incoming_data_unmatched.other_info is
	'other identifying information as found in <data>';
comment on column clin.incoming_data_unmatched.type is
	'the type of <data>, eg HL7, LDT, ...,
	 useful for selecting an importer';
comment on column clin.incoming_data_unmatched.data is
	'the raw data';

-- =============================================
grant select, insert, update, delete on
	clin.incoming_data_unmatched
	, clin.incoming_data_unmatched_pk_seq
to group "gm-doctors";

-- =============================================
-- do simple schema revision tracking
select log_script_insertion('$RCSfile: gmUnmatchedData-dynamic.sql,v $3', '$Revision: 1.2 $');

-- =============================================
-- $Log: gmUnmatchedData-dynamic.sql,v $
-- Revision 1.2  2005-11-27 13:00:59  ncq
-- - since schema "clin" exists now we better use it
--
-- Revision 1.1  2005/10/30 21:57:51  ncq
-- - incoming data tables: unmatched/unmatchable
--
--
