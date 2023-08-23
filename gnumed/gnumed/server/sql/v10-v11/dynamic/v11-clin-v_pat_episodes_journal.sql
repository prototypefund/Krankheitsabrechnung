-- ==============================================================
-- GNUmed database schema change script
--
-- License: GPL v2 or later
-- Author: Karsten Hilbert
-- 
-- ==============================================================
-- $Id: v11-clin-v_pat_episodes_journal.sql,v 1.1 2009-06-22 09:10:37 ncq Exp $
-- $Revision: 1.1 $

-- --------------------------------------------------------------
\set ON_ERROR_STOP 1

-- --------------------------------------------------------------
\unset ON_ERROR_STOP
drop view clin.v_pat_episodes_journal cascade;
\set ON_ERROR_STOP 1


create view clin.v_pat_episodes_journal as
select
	(select fk_patient from clin.encounter where pk = cep.fk_encounter)
		as pk_patient,
	cep.modified_when
		as modified_when,
	cep.modified_when
		as clin_when,
	coalesce (
		(select short_alias from dem.staff where db_user = cep.modified_by),
		'<' || cep.modified_by || '>'
	)
		as modified_by,
	'a'::text
		as soap_cat,
	_('Episode') || ': ' || cep.description || ' ('
		|| case when cep.is_open
			then _('open')
			else _('closed')
			end
		|| ')'
		as narrative,
	cep.fk_encounter
		as pk_encounter,
	cep.pk
		as pk_episode,
	cep.fk_health_issue
		as pk_health_issue,
	cep.pk
		as src_pk,
	'clin.episode'::text
		as src_table,
	cep.row_version
from
	clin.episode cep
;


grant select on clin.v_pat_episodes_journal TO GROUP "gm-doctors";
-- --------------------------------------------------------------
select gm.log_script_insertion('$RCSfile: v11-clin-v_pat_episodes_journal.sql,v $', '$Revision: 1.1 $');

-- ==============================================================
-- $Log: v11-clin-v_pat_episodes_journal.sql,v $
-- Revision 1.1  2009-06-22 09:10:37  ncq
-- - add revision
-- - make soap cat "a"
--
--