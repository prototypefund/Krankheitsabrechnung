-- ==============================================================
-- GNUmed database schema change script
--
-- Source database version: v2
-- Target database version: v3
--
-- What it does:
-- - ...
--
-- License: GPL v2 or later
-- Author: 
-- 
-- ==============================================================
-- $Id: cfg-cfg_str_array.sql,v 1.4 2007-09-24 23:31:17 ncq Exp $
-- $Revision: 1.4 $

-- --------------------------------------------------------------
\set ON_ERROR_STOP 1

-- --------------------------------------------------------------
insert into cfg.cfg_str_array
	(fk_item, value)
values (
	(select pk from cfg.cfg_item where workplace = 'Release 0.2.3'),
	'{"gmProviderInboxPlugin","gmNotebookedPatientEditionPlugin","gmEMRBrowserPlugin","gmNotebookedProgressNoteInputPlugin","gmEMRJournalPlugin","gmShowMedDocs","gmScanIdxMedDocsPlugin","gmXdtViewer","gmManual","gmConfigRegistry"}'
);

--comment on forgot_to_edit_comment is
--	'';

-- --------------------------------------------------------------
select public.log_script_insertion('$RCSfile: cfg-cfg_str_array.sql,v $', '$Revision: 1.4 $');

-- ==============================================================
-- $Log: cfg-cfg_str_array.sql,v $
-- Revision 1.4  2007-09-24 23:31:17  ncq
-- - remove begin; commit; as it breaks the bootstrapper
--
-- Revision 1.3  2006/12/29 11:33:19  ncq
-- - Release 0.2.3 default workplace is called just that, "Release 0.2.3"
--
-- Revision 1.2  2006/10/30 16:49:53  ncq
-- - add xdt viewer as plugin
--
-- Revision 1.1  2006/10/08 09:06:05  ncq
-- - add workplace def
--
-- Revision 1.4  2006/09/28 14:39:51  ncq
-- - add comment template
--
-- Revision 1.3  2006/09/18 17:32:53  ncq
-- - make more fool-proof
--
-- Revision 1.2  2006/09/16 21:47:37  ncq
-- - improvements
--
-- Revision 1.1  2006/09/16 14:02:36  ncq
-- - use this as a template for change scripts
--
--
