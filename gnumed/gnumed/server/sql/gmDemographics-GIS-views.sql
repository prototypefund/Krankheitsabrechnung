-- project: GNUmed

-- author: Horst Herb, Ian Haywood, Karsten Hilbert, Carlos Moro
-- copyright: authors
-- license: GPL v2 or later (details at http://gnu.org)

-- droppable components of GIS schema

-- $Source: /home/ncq/Projekte/cvs2git/vcs-mirror/gnumed/gnumed/server/sql/gmDemographics-GIS-views.sql,v $
-- $Revision: 1.31 $
-- ###################################################################
-- force terminate + exit(3) on errors if non-interactive
\set ON_ERROR_STOP 1

-- ===================================================================
-- -- dem.country --
COMMENT on table dem.country IS
	'countries coded per ISO 3166-1';
COMMENT on column dem.country.code IS
	'international two character country code as per ISO 3166-1';
COMMENT on column dem.country.deprecated IS
	'date when this country ceased officially to exist (if applicable)';

\unset ON_ERROR_STOP
alter table dem.country drop constraint no_linebreaks;
\set ON_ERROR_STOP 1

alter table dem.country
	add constraint no_linebreaks check (
		(position('\f' in coalesce(code, '') || coalesce(name, '')) = 0) and
		(position('\n' in coalesce(code, '') || coalesce(name, '')) = 0) and
		(position('\r' in coalesce(code, '') || coalesce(name, '')) = 0) and
		(position('\013' in coalesce(code, '') || coalesce(name, '')) = 0)
	);

-- -- dem.state --
select audit.add_table_for_audit('dem', 'state');

COMMENT on table dem.state is
	'state codes (country specific);
	 Richard agreed we should require pre-existence,
	 allow user to mail details for adding a state to developers';
COMMENT on column dem.state.code is
	'state code';
COMMENT on column dem.state.country is
	'2 character ISO 3166-1 country code';

\unset ON_ERROR_STOP
alter table dem.state drop constraint no_linebreaks;
\set ON_ERROR_STOP 1

alter table dem.state
	add constraint no_linebreaks check (
		(position('\f' in coalesce(code, '') || coalesce(country, '') || coalesce(name,'')) = 0) and
		(position('\n' in coalesce(code, '') || coalesce(country, '') || coalesce(name,'')) = 0) and
		(position('\r' in coalesce(code, '') || coalesce(country, '') || coalesce(name,'')) = 0) and
		(position('\013' in coalesce(code, '') || coalesce(country, '') || coalesce(name,'')) = 0)
	);

-- -- dem.urb --
select audit.add_table_for_audit('dem', 'urb');

COMMENT on table dem.urb IS
	'cities, towns, dwellings ..., eg. "official" places of residence';
COMMENT on column dem.urb.id_state IS
	'reference to information about country and state';
COMMENT on column dem.urb.postcode IS
	'default postcode for urb.name,
	 useful for all the smaller urbs that only have one postcode,
	 also useful as a default when adding new streets to an urb';
COMMENT on column dem.urb.name IS
	'the name of the city/town/dwelling';
COMMENT on column dem.urb.lat_lon is
	'the location of the urb, as lat/long co-ordinates. Ideally this would be NOT NULL';

\unset ON_ERROR_STOP
alter table dem.urb drop constraint no_linebreaks;
\set ON_ERROR_STOP 1

alter table dem.urb
	add constraint no_linebreaks check (
		(position('\f' in coalesce(postcode, '') || coalesce(name,'')) = 0) and
		(position('\n' in coalesce(postcode, '') || coalesce(name,'')) = 0) and
		(position('\r' in coalesce(postcode, '') || coalesce(name,'')) = 0) and
		(position('\013' in coalesce(postcode, '') || coalesce(name,'')) = 0)
	);

-- -- dem.street --
select audit.add_table_for_audit('dem', 'street');

COMMENT on table dem.street IS
	'street names, specific for distinct "urbs"';
COMMENT on column dem.street.id_urb IS
	'reference to information postcode, city, country and state';
COMMENT on column dem.street.name IS
	'name of this street';
COMMENT on column dem.street.postcode IS
	'postcode for systems (such as UK Royal Mail) which specify the street';
comment on column dem.street.suburb is
	'the suburb this street is in (if any)';
comment on column dem.street.lat_lon is
'the approximate location of the street, as lat/long co-ordinates';

\unset ON_ERROR_STOP
alter table dem.street drop constraint no_linebreaks;
\set ON_ERROR_STOP 1

alter table dem.street
	add constraint no_linebreaks check (
		(position('\f' in coalesce(postcode, '') || coalesce(suburb, '') || coalesce(name,'')) = 0) and
		(position('\n' in coalesce(postcode, '') || coalesce(suburb, '') || coalesce(name,'')) = 0) and
		(position('\r' in coalesce(postcode, '') || coalesce(suburb, '') || coalesce(name,'')) = 0) and
		(position('\013' in coalesce(postcode, '') || coalesce(suburb, '') || coalesce(name,'')) = 0)
	);

-- -- dem.address --
select audit.add_table_for_audit('dem', 'address');

comment on table dem.address is
	'an address aka a location, void of attached meaning such as type of address';
comment on column dem.address.id_street is
	'the street this address is at from
	 whence the urb is to be found, it
	 thus indirectly references dem.urb(id)';
comment on column dem.address.aux_street is
	'additional street-level information which
	 formatters would usually put on lines directly
	 below the street line of an address, such as
	 postal box directions in CA';
comment on column dem.address.number is
	'number of the house';
comment on column dem.address.subunit is
	'directions *below* the unit (eg.number) level,
	 such as appartment number, room number, level,
	 entrance or even verbal directions';
comment on column dem.address.addendum is
	'any additional information that
	 did not fit anywhere else';
comment on column dem.address.lat_lon is
	'the exact location of this address in latitude-longtitude';

-- ===================================================================
create or replace function dem.gm_upd_default_states()
	returns boolean
	language 'plpgsql'
	as '
declare
	_state_code text;
	_state_name text;
	_country_row record;
begin
	_state_code := ''??'';
	_state_name := ''state/territory/province/region not available'';

	-- add default state to countries needing one
	for _country_row in
		select distinct code from dem.country
		where code not in (
			select country from dem.state where code = _state_code
		)
	loop
		raise notice ''adding default state for [%]'', _country_row.code;
		execute ''insert into dem.state (code, country, name) values (''
				|| quote_literal(_state_code) || '', ''
				|| quote_literal(_country_row.code) || '', ''
				|| quote_literal(_state_name) || '');'';
	end loop;
	return true;
end;
';

select dem.gm_upd_default_states();

-- ===================================================================
-- if you suffer from performance problems when selecting from this view,
-- implement it as a real table
\unset ON_ERROR_STOP
drop view dem.v_basic_address;
\set ON_ERROR_STOP 1

create view dem.v_basic_address as
select
	adr.id as id,
	s.country as country_code,
	s.code as state_code,
	s.name as state,
	c.name as country,
	coalesce (str.postcode, urb.postcode) as postcode,
	urb.name as urb,
	adr.number as number,
	str.name as street,
	adr.addendum as addendum,
	coalesce (adr.lat_lon, str.lat_lon, urb.lat_lon) as lat_lon
from
	dem.address adr,
	dem.state s,
	dem.country c,
	dem.urb,
	dem.street str
where
	s.country = c.code
		and
	adr.id_street = str.id
		and
	str.id_urb = urb.id
		and
	urb.id_state = s.id;


-- ===================================================================
-- Functions to create urb, street and address.

\unset ON_ERROR_STOP
DROP function dem.create_urb(text, text, text, text);
\set ON_ERROR_STOP 1

CREATE function dem.create_urb(text, text, text, text) RETURNS integer AS '
DECLARE
	_urb ALIAS FOR $1;
	_urb_postcode ALIAS FOR $2;	
	_state_code ALIAS FOR $3;
	_country_code ALIAS FOR $4;

 	_state_id integer;
	_urb_id integer;

	msg text;
BEGIN
 	-- get state
 	SELECT INTO _state_id s.id from dem.state s WHERE s.code = _state_code and s.country = _country_code;
 	IF NOT FOUND THEN
		msg := ''Cannot set address ['' || _country_code || '', '' || _state_code || '', '' || _urb || '', '' || _urb_postcode || ''].'';
		RAISE EXCEPTION ''=> %'', msg;
 	END IF;
	-- get/create and return urb
	SELECT INTO _urb_id u.id from dem.urb u WHERE u.name ILIKE _urb AND u.id_state = _state_id;
	IF FOUND THEN
		RETURN _urb_id;
	END IF;
	INSERT INTO dem.urb (name, postcode, id_state) VALUES (_urb, _urb_postcode, _state_id);
	RETURN currval(''dem.urb_id_seq'');
END;' LANGUAGE 'plpgsql';

COMMENT ON function dem.create_urb(text, text, text, text) IS
	'This function takes a parameters the name of the urb,\n
	the postcode of the urb, the name of the state and the\n
	name of the country.\n
	If the country or the state does not exists in the tables,\n
	the function fails.\n
	At first, the urb is tried to be retrieved according to the\n
	supplied information. If the fields do not match exactly an\n
	existing row, a new urb is created and returned.';

\unset ON_ERROR_STOP
DROP function dem.create_street(text, text, text, text, text);
\set ON_ERROR_STOP 1

CREATE function dem.create_street(text, text, text, text, text) RETURNS integer AS '
DECLARE
	_street ALIAS FOR $1;
	_postcode ALIAS FOR $2;
	_urb ALIAS FOR $3;
	_state ALIAS FOR $4;
	_country ALIAS FOR $5;

	_urb_id integer;
	_street_id integer;

	msg text;
BEGIN
	-- create/get urb
	SELECT INTO _urb_id dem.create_urb(_urb, _postcode, _state, _country);
	-- create/get and return street
	SELECT INTO _street_id s.id from dem.street s WHERE s.name ILIKE _street AND s.id_urb = _urb_id AND postcode ILIKE _postcode;
	IF FOUND THEN
		RETURN _street_id;
	END IF;
	INSERT INTO dem.street (name, postcode, id_urb) VALUES (_street, _postcode, _urb_id);
	RETURN currval(''dem.street_id_seq'');
END;' LANGUAGE 'plpgsql';

COMMENT ON function dem.create_street(text, text, text, text, text) IS
	'This function takes a parameters the name of the street,\n
	the postal code, the name of the urb,\n
	the postcode of the urb, the name of the state and the\n
	name of the country.\n
	If the country or the state does not exists in the tables,\n
	the function fails.\n
	At first, both the urb and street are tried to be retrieved according to the\n
	supplied information. If the fields do not match exactly an\n
	existing row, a new urb is created or a new street is created and returned.';

\unset ON_ERROR_STOP
DROP function dem.create_address(text, text, text, text, text, text);
\set ON_ERROR_STOP 1

CREATE function dem.create_address(text, text, text, text, text, text) RETURNS integer AS '
DECLARE
	_number ALIAS FOR $1;
	_street ALIAS FOR $2;
	_postcode ALIAS FOR $3;
	_urb ALIAS FOR $4;
	_state ALIAS FOR $5;
	_country ALIAS FOR $6;
	
	_street_id integer;
	_address_id integer;
	
	msg text;
BEGIN
	-- create/get street
	SELECT INTO _street_id dem.create_street(_street, _postcode, _urb, _state, _country);
	-- create/get and return address
	SELECT INTO _address_id a.id from dem.address a WHERE a.number ILIKE _number and a.id_street = _street_id;
	IF FOUND THEN
		RETURN _address_id;
	END IF;
	INSERT INTO dem.address (number, id_street) VALUES ( _number, _street_id);
	RETURN currval(''dem.address_id_seq'');
END;' LANGUAGE 'plpgsql';

COMMENT ON function dem.create_address(text, text, text, text, text, text) IS
	'This function takes as parameters the number of the address,\n
	the name of the street, the postal code of the address, the\n
	name of the urb, the name of the state and the name of the\n
	country. If the country or the state does not exists in the\n
	database, the function fails.\n
	At first, the urb, the street and the address are tried to be\n
	retrieved according to the supplied information. If the fields\n
	do not match exactly an existing row, a new urb or street is\n
	created or a new address is created and returned.';


-- ===================================================================
\unset ON_ERROR_STOP
drop view dem.v_zip2street cascade;
\set ON_ERROR_STOP 1

create view dem.v_zip2street as
	select
		coalesce (str.postcode, urb.postcode) as postcode,
		str.name as street,
		str.suburb as suburb,
		stt.name as state,
		stt.code as code_state,
		urb.name as urb,
		c.name as country,
		_(c.name) as l10n_country,
		stt.country as code_country
	from
		dem.street str,
		dem.urb,
		dem.state stt,
		dem.country c
	where
		str.postcode is not null
			and
		str.id_urb = urb.id
			and
		urb.id_state = stt.id
			and
		stt.country = c.code
;

comment on view dem.v_zip2street is
	'list known data for streets that have a zip code';

-- ===================================================================
\unset ON_ERROR_STOP
drop view dem.v_zip2urb;
\set ON_ERROR_STOP 1

create view dem.v_zip2urb as
	select
		urb.postcode as postcode,
		urb.name as urb,
		stt.name as state,
		stt.code as code_state,
		_(c.name) as country,
		stt.country as code_country
	from
		dem.urb,
		dem.state stt,
		dem.country c
	where
		urb.postcode is not null
			and
		urb.id_state = stt.id
			and
		stt.country = c.code
;

comment on view dem.v_zip2urb is
	'list known data for urbs that have a zip code';

-- ===================================================================
\unset ON_ERROR_STOP
drop view dem.v_uniq_zipped_urbs;
\set ON_ERROR_STOP 1

create view dem.v_uniq_zipped_urbs as
	-- all the cities that
	select
		urb.postcode as postcode,
		urb.name as name,
		stt.name as state,
		stt.code as code_state,
		c.name as country,
		_(c.name) as l10n_country,
		stt.country as code_country
	from
		dem.urb,
		dem.state stt,
		dem.country c
	where
		-- have a zip code
		urb.postcode is not null
			and
		-- are not found in "street" with this zip code
		not exists (
			select 1 from
				dem.v_zip2street vz2str,
				dem.urb
			where
				vz2str.postcode = urb.postcode
					and
				vz2str.urb = urb.name
			) and
		urb.id_state = stt.id
			and
		stt.country = c.code
;

comment on view dem.v_uniq_zipped_urbs is
	'convenience view that selects urbs which:
	 - have a zip code
	 - are not referenced in table "street" with that zip code';

-- ===================================================================
\unset ON_ERROR_STOP
drop view dem.v_zip2data;
\set ON_ERROR_STOP 1

create view dem.v_zip2data as
	select
		vz2s.postcode as zip,
		vz2s.street,
		vz2s.suburb,
		vz2s.urb,
		vz2s.state,
		vz2s.code_state,
		vz2s.country,
		vz2s.l10n_country,
		vz2s.code_country
	from dem.v_zip2street vz2s
		union
	select
		vuzu.postcode as zip,
		null as street,
		null as suburb,
		vuzu.name as urb,
		vuzu.state,
		vuzu.code_state,
		vuzu.country,
		vuzu.l10n_country,
		vuzu.code_country
	from
		dem.v_uniq_zipped_urbs vuzu
;

comment on view dem.v_zip2data is
	'aggregates nearly all known data per zip code';

-- ===================================================================
GRANT select ON
	dem.v_basic_address,
	dem.v_zip2street,
	dem.v_zip2urb,
	dem.v_zip2data
TO GROUP "gm-doctors";

GRANT select, delete, insert, update ON
	dem.v_basic_address
TO GROUP "gm-doctors";


-- ===================================================================
-- do simple schema revision tracking
delete from gm_schema_revision where filename='$RCSfile: gmDemographics-GIS-views.sql,v $';
INSERT INTO gm_schema_revision (filename, version) VALUES('$RCSfile: gmDemographics-GIS-views.sql,v $', '$Revision: 1.31 $');

-- ===================================================================
-- $Log: gmDemographics-GIS-views.sql,v $
-- Revision 1.31  2006-06-05 21:38:09  ncq
-- - cleanup
--
-- Revision 1.30  2006/06/04 22:23:45  ncq
-- - add l10n_country to v_zip2data, v_zip_uniq_urbs and v_zip2street
--
-- Revision 1.29  2006/04/29 12:18:36  sjtan
--
-- md5 not working as an index, so use a trigger to check unique narrative.
-- demographic function named in demographic schema.
--
-- Revision 1.28  2006/02/19 13:46:47  ncq
-- - factor out dynamic DDL
-- - disallow CR/LF/FF/VT in many single-line demographics fields
--
-- Revision 1.27  2006/01/09 13:46:19  ncq
-- - adjust to schema "i18n" qualification
--
-- Revision 1.26  2006/01/06 10:12:02  ncq
-- - add missing grants
-- - add_table_for_audit() now in "audit" schema
-- - demographics now in "dem" schema
-- - add view v_inds4vaccine
-- - move staff_role from clinical into demographics
-- - put add_coded_term() into "clin" schema
-- - put German things into "de_de" schema
--
-- Revision 1.25  2005/09/28 22:49:04  ncq
-- - update gm_upd_default_states()
--
-- Revision 1.24  2005/09/19 16:20:47  ncq
-- - gm_upd_default_states()
--
-- Revision 1.23  2005/07/14 21:31:42  ncq
-- - partially use improved schema revision tracking
--
-- Revision 1.22  2005/06/03 13:36:11  cfmoro
-- Pass state and country codes instead of their names, safer and more consistent
--
-- Revision 1.21  2005/05/19 16:33:34  ncq
-- - in v_basic_address properly handle country/state + *_code
--
-- Revision 1.20  2005/05/17 17:34:37  ncq
-- - make create_*() work
--
-- Revision 1.19  2005/05/14 15:03:29  ncq
-- - lots of cleanup
--
-- Revision 1.18  2005/04/28 19:52:59  ncq
-- - some fixes by Carlos
--
-- Revision 1.17  2005/04/23 17:45:16  ncq
-- - create_*() by Carlos
--
-- Revision 1.16  2005/02/20 09:46:08  ihaywood
-- demographics module with load a patient with no exceptions
--
-- Revision 1.15  2005/01/24 17:57:43  ncq
-- - cleanup
-- - Ian's enhancements to address and forms tables
--
-- Revision 1.14  2004/12/20 18:52:02  ncq
-- - Ian reworked v_basic_address
--
-- Revision 1.13  2004/12/15 09:24:49  ncq
-- - addr_id -> id, followup v_basic_address changes
--
-- Revision 1.12  2004/12/15 04:18:03  ihaywood
-- minor changes
-- pointless irregularity in v_basic_address
-- extended v_basic_person to more fields.
--
-- Revision 1.11  2004/09/19 17:13:48  ncq
-- - propagate suburb into all the right places
--
-- Revision 1.10  2004/07/17 20:57:53  ncq
-- - don't use user/_user workaround anymore as we dropped supporting
--   it (but we did NOT drop supporting readonly connections on > 7.3)
--
-- Revision 1.9  2004/04/10 01:48:31  ihaywood
-- can generate referral letters, output to xdvi at present
--
-- Revision 1.8  2004/01/05 00:45:41  ncq
-- - drop rule wants relation name
--
-- Revision 1.7  2003/12/29 15:33:43  uid66147
-- - translate country.name in views
--
-- Revision 1.6  2003/09/21 06:54:13  ihaywood
-- sane permissions
--
-- Revision 1.5  2003/08/10 15:18:22  ncq
-- - eventually make the zip2data view work with help from Mike Mascari (pgsql-general)
--
-- Revision 1.4  2003/08/10 01:26:50  ncq
-- - make v_zip2data compile again
--
-- Revision 1.3  2003/08/10 01:07:46  ncq
-- - adapt to lnk_a2b table naming plan
-- - add v_zip2... views
--
-- Revision 1.2  2003/08/02 13:15:42  ncq
-- - better table aliases in complex queries
-- - a few more audit tables
--
-- Revision 1.1  2003/08/02 10:41:29  ncq
-- - rearranging files for clarity as to services/schemata
--
