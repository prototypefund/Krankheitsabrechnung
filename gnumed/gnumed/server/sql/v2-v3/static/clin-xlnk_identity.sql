-- ==============================================================
-- GNUmed database schema change script
--
-- Source database version: v2
-- Target database version: v3
--
-- What it does:
-- - drop clin.xlnk_identity
--
-- License: GPL v2 or later
-- Author: Karsten Hilbert
-- 
-- ==============================================================
-- $Id: clin-xlnk_identity.sql,v 1.2 2007-09-24 23:31:17 ncq Exp $
-- $Revision: 1.2 $

-- --------------------------------------------------------------
\set ON_ERROR_STOP 1

-- --------------------------------------------------------------
drop table clin.xlnk_identity;

delete from audit.audited_tables where schema = 'clin' and table_name = 'xlnk_identity';

-- --------------------------------------------------------------
select public.log_script_insertion('$RCSfile: clin-xlnk_identity.sql,v $', '$Revision: 1.2 $');

-- ==============================================================
-- $Log: clin-xlnk_identity.sql,v $
-- Revision 1.2  2007-09-24 23:31:17  ncq
-- - remove begin; commit; as it breaks the bootstrapper
--
-- Revision 1.1  2006/10/24 13:08:25  ncq
-- - mainly changes due to dropped clin.xlnk_identity
--
--
