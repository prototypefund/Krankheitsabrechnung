-- ==============================================================
-- GNUmed database schema change script
--
-- License: GPL v2 or later
-- Author: Karsten Hilbert
-- 
-- ==============================================================
-- $Id: v10-clin-waiting_list-static.sql,v 1.2 2009-01-17 23:16:52 ncq Exp $
-- $Revision: 1.2 $

-- --------------------------------------------------------------
\set ON_ERROR_STOP 1

-- --------------------------------------------------------------
alter table clin.waiting_list
	add column area
		text;

alter table audit.log_waiting_list
	add column area
		text;

-- --------------------------------------------------------------
select gm.log_script_insertion('$RCSfile: v10-clin-waiting_list-static.sql,v $', '$Revision: 1.2 $');

-- ==============================================================
-- $Log: v10-clin-waiting_list-static.sql,v $
-- Revision 1.2  2009-01-17 23:16:52  ncq
-- - cleanup
--
-- Revision 1.1  2009/01/16 13:32:19  ncq
-- - new
--
--