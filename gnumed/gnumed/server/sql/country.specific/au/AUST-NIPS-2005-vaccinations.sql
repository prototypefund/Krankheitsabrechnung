-- Project: GNUmed - service "clinical" -- Australian vaccination schedules
-- ========================================================================
-- $Source: /home/ncq/Projekte/cvs2git/vcs-mirror/gnumed/gnumed/server/sql/country.specific/au/AUST-NIPS-2005-vaccinations.sql,v $
-- $Revision: 1.2 $
-- license: GPL v2 or later
-- author: Syan Tan

-- ===================================================================
-- force terminate + exit(3) on errors if non-interactive
\set ON_ERROR_STOP 1

-- ===================================================================
delete from clin.vaccination_course where fk_recommended_by = (select pk from ref_source where name_short='Aust NIPS');

delete from ref_source where name_short = 'Aust NIPS';
insert into ref_source (
	name_short,
	name_long,
	version,
	source
) values (
	'Aust NIPS',
	'Australian National Immunization Program',
	'2005',
	'Syan Tan'
);

-- ===================================================================

insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'hepatitis B'), 4, 'hepatitis B (Aust NIPS 2005)');

insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'hepatitis B'), 5, 'hepatitis B (older cohort - Aust NIPS 2005)');

insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'poliomyelitis'), 4, 'poliomyelitis (Aust NIPS 2005)');
insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'diphtheria'), 4, 'diphtheria (Aust NIPS 2005)');
insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'pertussis'), 4, 'pertussis (Aust NIPS 2005)');
insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'tetanus'), 4, 'tetanus (Aust NIPS 2005)');


insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'diphtheria'), 5 , 'diphtheria (older cohort Aust NIPS 2005)');
insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'pertussis'), 5, 'pertussis (older cohort Aust NIPS 2005)');
insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'tetanus'), 5, 'tetanus (older cohort Aust NIPS 2005)');


insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'haemophilus influenzae b'), 4, 'haemophilus influenzae b (Aust NIPS 2005)');

insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'pneumococcus'), 4, 'pneumoccocus (Aust NIPS 2005)');

insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'meningococcus C'), 4, 'meningococcus C (Aust NIPS 2005)');
insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'measles'), 4, 'measles (Aust NIPS 2005)');
insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'mumps'), 4, 'mumps (Aust NIPS 2005)');
insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'rubella'), 4, 'rubella (Aust NIPS 2005)');

insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'varicella'), 4, 'varicella (Aust NIPS 2005)');


insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'varicella'), 5, 'varicella (older cohort Aust NIPS 2005)');




insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'pneumococcus'), 6, 'high risk pneumococcus (Aust NIPS 2005)');


insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'hepatitis A'), 6, 'high risk Hepatitis A (Aust NIPS 2005)');


insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'influenza'), 4 , 'influenza (Aust NIPS 2005)');



insert into clin.vaccination_course(  fk_indication, fk_recommended_by, comment ) values ( (select id from clin.vacc_indication where description = 'influenza'), 6, 'high risk influenza (Aust NIPS 2005)');



insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'hepatitis B' and r.fk_recommended_by = 4) , 1 , interval '1 minute' , 
interval '1 week' , null);

insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'hepatitis B' and r.fk_recommended_by = 4) , 2 , interval '2 months' , 
interval '3 months' , interval '1 month' );

insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'hepatitis B' and r.fk_recommended_by = 4) , 3 , interval '4 months' , 
interval '5 months' , interval '1 month' );

insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'hepatitis B' and r.fk_recommended_by = 4) , 4 , interval '12 months' , 
interval '13 months' , interval '2 months' );


insert into clin.vaccination_definition ( fk_course ,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'hepatitis B' and r.fk_recommended_by = 5) , 1 , interval '10 years' , 
interval '13 years' , null );

insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'haemophilus influenzae b' and r.fk_recommended_by = 4) , 1 , interval '2 months' , 
interval '3 months' , null );

insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'haemophilus influenzae b' and r.fk_recommended_by = 4) , 2 , interval '4 months' , 
interval '5 months' , interval '1 month' );

insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'haemophilus influenzae b' and r.fk_recommended_by = 4) , 3 , interval '12 months' , 
interval '13 months' , interval '2 month' );

insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'poliomyelitis' and r.fk_recommended_by = 4) , 1 , interval '2 months' , 
interval '3 months' , null);

insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'poliomyelitis' and r.fk_recommended_by = 4) , 2 , interval '4 months' , 
interval '5 months' , interval '1 month' );

insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'poliomyelitis' and r.fk_recommended_by = 4) , 3 , interval '6 months' , 
interval '13 months' , interval '1 month' );


insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'poliomyelitis' and r.fk_recommended_by = 4) , 4 , interval '4 years' , 
interval '5 years' , interval '42 months' );

insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'diphtheria' and r.fk_recommended_by = 4) , 1 , interval '2 months' , 
interval '3 months' , null);

insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'diphtheria' and r.fk_recommended_by = 4) , 2 , interval '4 months' , 
interval '5 months' , interval '1 month' );

insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'diphtheria' and r.fk_recommended_by = 4) , 3 , interval '6 months' , 
interval '13 months' , interval '1 month' );


insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'diphtheria' and r.fk_recommended_by = 4) , 4 , interval '4 years' , 
interval '5 years' , interval '6 month' );


insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'diphtheria'  and r.fk_recommended_by = 5) , 5 , interval '15 years' , 
interval '17 years' ,interval '1 month');



insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'tetanus' and r.fk_recommended_by = 4) , 1 , interval '2 months' , 
interval '3 months' , null );

insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'tetanus' and r.fk_recommended_by = 4) , 2 , interval '4 months' , 
interval '5 months' , interval '1 month' );

insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'tetanus' and r.fk_recommended_by = 4) , 3 , interval '6 months' , 
interval '13 months' , interval '1 month' );


insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'tetanus' and r.fk_recommended_by = 4) , 4 , interval '4 years' , 
interval '5 years' , interval '6 month' );


insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'tetanus'  and r.fk_recommended_by = 5) , 5 , interval '15 years' , 
interval '17 years' , interval '1 month' );



insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'pertussis' and r.fk_recommended_by = 4) , 1 , interval '2 months' , 
interval '3 months' ,null );

insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'pertussis' and r.fk_recommended_by = 4) , 2 , interval '4 months' , 
interval '5 months' , interval '1 month' );

insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'pertussis' and r.fk_recommended_by = 4) , 3 , interval '6 months' , 
interval '13 months' , interval '1 month' );


insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'pertussis' and r.fk_recommended_by = 4) , 4 , interval '4 years' , 
interval '5 years' , interval '6 month' );


insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'pertussis'  and r.fk_recommended_by = 5) , 5 , interval '15 years' , 
interval '17 years' , interval '1 month');




insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'measles' and r.fk_recommended_by = 4) , 1, interval '12 months' , 
interval '13 months' , null );


insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'mumps' and r.fk_recommended_by = 4) , 1, interval '12 months' , 
interval '13 months' , null );



insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'rubella' and r.fk_recommended_by = 4) , 1, interval '12 months' , 
interval '13 months' , null );


insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'measles' and r.fk_recommended_by = 4) , 2, interval '4 years' , 
interval '4 years' , interval '1 month'  );


insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'mumps' and r.fk_recommended_by = 4) , 2, interval '4 years' , 
interval '4 years' , interval '1 month'   );



insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'rubella' and r.fk_recommended_by = 4) , 2, interval '4 years' , 
interval '4 years' , interval '1 month'  );




insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'meningococcus C' and r.fk_recommended_by = 4) , 1, interval '12 months' , 
interval '13 months' , null );


insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'varicella' and r.fk_recommended_by = 4) , 1, interval '18 months' , 
interval '24 months' , null );



insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'varicella' and r.fk_recommended_by = 5) , 1, interval '10 years' , 
interval '13 years' , null );



insert into clin.vaccination_definition (
	fk_course,seq_no,
	min_age_due,
	max_age_due,
	min_interval
) values (
	(select r.pk
		from clin.vaccination_course r, clin.vacc_indication i
		where
			r.fk_indication = i.id and
			i.description = 'influenza' and
			r.comment not like 'high risk%' and
			r.fk_recommended_by = 4
	),
	1,
	interval '65 years',
	interval '65 years',
	null
);


insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'pneumococcus' and r.comment not like 'high risk%' and r.fk_recommended_by = 4) , 1, interval '65 years' , 
interval '65 years' , null );



insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'influenza' and r.comment like 'high risk%' and r.fk_recommended_by = 6) , 1, interval '50 years' , 
interval '65 years' , null );


insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'pneumococcus' and r.comment like 'high risk%' and r.fk_recommended_by = 6) , 1, interval '18 months' , 
interval '24 months' , null );

insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'pneumococcus' and r.comment like 'high risk%' and r.fk_recommended_by = 6) , 2, interval '50 years' , 
interval '65 years' , interval '48 years' );




insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'hepatitis A' and r.fk_recommended_by = 6) , 1, interval '12 months' , 
interval '24 months' , null );



insert into clin.vaccination_definition ( fk_course,seq_no,   min_age_due, max_age_due, min_interval ) values ( ( select r.pk from clin.vaccination_course r , clin.vacc_indication i where r.fk_indication = i.id and i.description = 'hepatitis A' and r.fk_recommended_by = 6) , 2, interval '18 months' , 
interval '24 months' , interval '6 months' );


-- ===================================================================
-- $Log: AUST-NIPS-2005-vaccinations.sql,v $
-- Revision 1.2  2006-03-04 16:21:25  ncq
-- - adjust to name changes
--
-- Revision 1.1  2006/01/01 17:57:07  ncq
-- - Australian vacc schedules by Syan
--
--
