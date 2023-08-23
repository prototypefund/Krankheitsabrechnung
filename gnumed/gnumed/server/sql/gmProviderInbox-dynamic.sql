-- =============================================
-- GNUmed - dynamic tables for the provider inbox
-- =============================================
-- $Source: /home/ncq/Projekte/cvs2git/vcs-mirror/gnumed/gnumed/server/sql/gmProviderInbox-dynamic.sql,v $
-- $Id: gmProviderInbox-dynamic.sql,v 1.11 2006-10-08 09:12:03 ncq Exp $
-- license: GPL v2 or later
-- author: Karsten.Hilbert@gmx.net

-- =============================================
-- force terminate + exit(3) on errors if non-interactive
\set ON_ERROR_STOP 1

-- ---------------------------------------------
comment on table dem.inbox_item_category is
	'Holds the various categories of messages that
	 can show up in the provider inbox.';
comment on column dem.inbox_item_category.description is '
"clinical"\n
"admin"\n
"personal"\n
...';
comment on column dem.inbox_item_category.is_user is
	'whether this category was added locally,
	 as to be left alone by database upgrades';

-- ---------------------------------------------
comment on table dem.inbox_item_type is
	'Holds the various types of messages that can
	 show up in the provider inbox.';
comment on column dem.inbox_item_type.fk_inbox_item_category is
	'The category of this item type.';
comment on column dem.inbox_item_type.description is
	'the various types of inbox items';
comment on column dem.inbox_item_type.is_user is
	'whether this type was added locally,
	 as to be left alone by database upgrades';

-- ---------------------------------------------
comment on table dem.provider_inbox is
	'Holds per-provider messages.';
comment on column dem.provider_inbox.fk_staff is
	'the member of staff this message is addressed to';
comment on column dem.provider_inbox.fk_inbox_item_type is
	'the item (message) type';
comment on column dem.provider_inbox.comment is
	'a free-text comment, may be NULL but not empty';
comment on column dem.provider_inbox.ufk_context is
	'an optional, *u*nchecked *f*oreign *k*ey, it is up to
	 the application to know what this points to, it will
	 have to make sense within the context of the combination
	 of staff ID, item type, and comment';
comment on column dem.provider_inbox.data is
	'arbitrary data an application might wish to attach to
	 the message, like a cookie, basically';
comment on column dem.provider_inbox.importance is
	'the relative importance of this message:\n
	 -1: lower than most things already in the inbox ("low")\n
	  0: same as most things ("standard")\n
	  1: higher than most things already there ("high")';

-- ---------------------------------------------
\unset ON_ERROR_STOP
drop view dem.v_inbox_item_type cascade;
\set ON_ERROR_STOP 1

create view dem.v_inbox_item_type as
select
	it.description as type,
	_(it.description) as l10n_type,
	ic.description as category,
	_(ic.description) as l10n_category,
	it.is_user as is_user_type,
	ic.is_user as is_user_category,
	it.pk as pk_type,
	it.fk_inbox_item_category as pk_category
from
	dem.inbox_item_type it,
	dem.inbox_item_category ic
where
	it.fk_inbox_item_category = ic.pk
;

-- ---------------------------------------------
create view dem.v_provider_inbox as
select
	(select short_alias from dem.staff where dem.staff.pk = pi.fk_staff) as provider,
	pi.importance,
	vit.category,
	vit.l10n_category,
	vit.type,
	vit.l10n_type,
	pi.comment,
	pi.ufk_context as pk_context,
	pi.data as data,
	pi.pk as pk_provider_inbox,
	pi.fk_staff as pk_staff,
	vit.pk_category,
	pi.fk_inbox_item_type as pk_type
from
	dem.provider_inbox pi,
	dem.v_inbox_item_type vit
where
	pi.fk_inbox_item_type = vit.pk_type

union

select
	(select short_alias from dem.staff where dem.staff.pk = vo4dnd.pk_intended_reviewer)
		as provider,
	0	as importance,
	'clinical'
		as category,
	_('clinical')
		as l10n_category,
	'review docs'
		as type,
	_('review docs')
		as l10n_type,
	(select _('unreviewed documents for patient') || ' [' || vbp.lastnames || ', ' || vbp.firstnames || ']'
	 from dem.v_basic_person vbp
	 where vbp.pk_identity=vo4dnd.pk_patient)
	 	as comment,
	vo4dnd.pk_patient
		as pk_context,
	NULL
		as data,
	NULL
		as pk_provider_inbox,
	vo4dnd.pk_intended_reviewer
		as pk_staff,
	(select pk_category from dem.v_inbox_item_type where type='review docs')
		as pk_category,
	(select pk_type from dem.v_inbox_item_type where type='review docs')
		as pk_type
from
	blobs.v_obj4doc_no_data vo4dnd
where
	reviewed is False
;

select i18n.i18n('unreviewed documents for patient');

-- =============================================
GRANT SELECT, INSERT, UPDATE, DELETE ON
	dem.provider_inbox
	, dem.provider_inbox_pk_seq
	, dem.inbox_item_type
	, dem.inbox_item_type_pk_seq
TO GROUP "gm-doctors";

GRANT SELECT ON
	dem.v_provider_inbox
TO GROUP "gm-doctors";

-- =============================================
-- do simple schema revision tracking
select log_script_insertion('$RCSfile: gmProviderInbox-dynamic.sql,v $2', '$Revision: 1.11 $');

-- =============================================
-- $Log: gmProviderInbox-dynamic.sql,v $
-- Revision 1.11  2006-10-08 09:12:03  ncq
-- - remove file level comment
--
-- Revision 1.10  2006/05/16 16:01:06  ncq
-- - improve inbox view and prepare for translation
--
-- Revision 1.9  2006/05/16 08:21:48  ncq
-- - remove field duplication from inbox view
-- - UNION in unreviewed documents - auto-messages in your inbox :-)
--
-- Revision 1.8  2006/05/15 20:50:57  ncq
-- - add pk_item, pk_type to inbox view
-- - add grants
--
-- Revision 1.7  2006/02/02 17:55:35  ncq
-- - add comment
--
-- Revision 1.6  2006/01/23 22:10:57  ncq
-- - staff.sign -> .short_alias
--
-- Revision 1.5  2006/01/22 18:13:37  ncq
-- - add "data" column to provider inbox and add to view
-- - improve comments
-- - default importance to 0
--
-- Revision 1.4  2006/01/09 13:44:02  ncq
-- - add inbox item type category and adjust view
--
-- Revision 1.3  2006/01/08 17:40:04  ncq
-- - fixed syntax error with "where" where no where belonged
--
-- Revision 1.2  2006/01/07 17:53:32  ncq
-- - proper grants for provider inbox
-- - dynamic staff re provider inbox added
--
-- Revision 1.1  2006/01/07 15:22:23  ncq
-- - initial attempt at provider inbox tables
--
