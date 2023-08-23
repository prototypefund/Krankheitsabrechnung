-- ==============================================================
-- GNUmed database schema change script
--
-- Source database version: v2
-- Target database version: v3
--
-- License: GPL v2 or later
-- Author: Karsten Hilbert
-- 
-- ==============================================================
-- $Id: transfer_users.sql,v 1.1 2007-01-04 22:58:14 ncq Exp $
-- $Revision: 1.1 $

-- --------------------------------------------------------------
\set ON_ERROR_STOP 1

select gm_transfer_users('gnumed_v3'::text);

-- ==============================================================
-- $Log: transfer_users.sql,v $
-- Revision 1.1  2007-01-04 22:58:14  ncq
-- - new
--
-- Revision 1.1  2006/12/12 18:11:54  ncq
-- - actually transfer users, too
--
-- Revision 1.5  2006/10/24 13:09:45  ncq
-- - What it does duplicates the change log so axe it
--
