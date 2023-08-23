-- GNUmed PUBLIC database accounts

-- use for publicly accessible GNUmed databases

-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- !! NEVER EVER use those accounts/passwords in a  !!
-- !! production database. As they are in CVS know- !!
-- !! ledge about them is PUBLIC and thus extremely !!
-- !! insecure. DO NOT USE FOR PRODUCTION.          !!
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

-- $Source: /home/ncq/Projekte/cvs2git/vcs-mirror/gnumed/gnumed/server/sql/gmPublicAccounts.sql,v $
-- $Id: gmPublicAccounts.sql,v 1.8 2006-02-02 16:20:46 ncq Exp $
-- GPL v2 or later
-- author: Karsten.Hilbert@gmx.net
-- ===================================================================
-- don't fail if user already exists
\unset ON_ERROR_STOP

-- Someone know a way of telling VALID UNTIL that the
-- value is CURRENT_DATE + interval '4 months' ?

-- ===================================================
select gm_create_user('any-doc', 'any-doc');

-- ===================================================
-- do simple schema revision tracking
INSERT INTO gm_schema_revision (filename, version) VALUES('$RCSfile: gmPublicAccounts.sql,v $', '$Revision: 1.8 $');

-- ===================================================
-- $Log: gmPublicAccounts.sql,v $
-- Revision 1.8  2006-02-02 16:20:46  ncq
-- - use gm_create_user()
--
-- Revision 1.7  2005/09/19 16:38:51  ncq
-- - adjust to removed is_core from gm_schema_revision
--
-- Revision 1.6  2005/07/14 21:31:42  ncq
-- - partially use improved schema revision tracking
--
-- Revision 1.5  2004/07/17 20:57:53  ncq
-- - don't use user/_user workaround anymore as we dropped supporting
--   it (but we did NOT drop supporting readonly connections on > 7.3)
--
-- Revision 1.4  2003/06/10 08:56:59  ncq
-- - schema_revision -> gm_schema_revision
--
-- Revision 1.3  2003/05/12 12:43:39  ncq
-- - gmI18N, gmServices and gmSchemaRevision are imported globally at the
--   database level now, don't include them in individual schema file anymore
--
-- Revision 1.2  2003/04/29 12:35:39  ncq
-- - uncomment schema revision insertion
--
-- Revision 1.1  2003/04/01 13:03:55  ncq
-- - for public databases
--
-- Revision 1.5  2003/02/07 14:33:21  ncq
-- - can't use schema tracking since at server level we aren't guarantueed to have that
--
-- Revision 1.4  2003/02/04 12:22:53  ncq
-- - valid until in create user cannot do a sub-query :-(
-- - columns "owner" should really be of type "name" if defaulting to "CURRENT_USER"
-- - new functions set_curr_lang(*)
--
-- Revision 1.3  2003/01/30 09:02:13  ncq
-- - don't fail on failure to insert into schema revision table
--
-- Revision 1.2  2003/01/20 12:11:46  ncq
-- - typo
--
-- Revision 1.1  2003/01/19 15:30:32  ncq
-- - a few test users
--
