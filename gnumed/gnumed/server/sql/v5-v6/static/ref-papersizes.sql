-- ==============================================================
-- GNUmed database schema change script
--
-- Source database version: v5
-- Target database version: v6
--
-- License: GPL v2 or later
-- Author: Karsten Hilbert
-- 
-- ==============================================================
-- $Id: ref-papersizes.sql,v 1.2 2007-05-18 09:23:55 ncq Exp $
-- $Revision: 1.2 $

-- --------------------------------------------------------------
\set ON_ERROR_STOP 1

-- --------------------------------------------------------------
-- cleanup
\unset ON_ERROR_STOP
drop table ref.papersizes cascade;
\set ON_ERROR_STOP 1

-- create new table
create table ref.papersizes (
	pk serial
		primary key,
	name text
		unique
		not null,
	size point
		not null
);

-- transfer data
insert into ref.papersizes select * from public.papersizes;

-- adjust foreign keys
\unset ON_ERROR_STOP
alter table public.form_print_defs
	drop constraint "form_print_defs_fk_papersize_fkey";
alter table public.form_print_defs
	drop constraint "$2";
\set ON_ERROR_STOP 1

alter table public.form_print_defs
	add foreign key(fk_papersize)
		references ref.papersizes(pk)
		on update cascade
		on delete restrict;

-- drop old table
drop table public.papersizes;

-- --------------------------------------------------------------
select public.log_script_insertion('$RCSfile: ref-papersizes.sql,v $', '$Revision: 1.2 $');

-- ==============================================================
-- $Log: ref-papersizes.sql,v $
-- Revision 1.2  2007-05-18 09:23:55  ncq
-- - foreign keys have other names on 7.4
--
-- Revision 1.1  2007/05/07 16:27:12  ncq
-- - move over from public
--
--