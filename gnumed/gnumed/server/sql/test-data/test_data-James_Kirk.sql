-- Projekt GNUmed
-- test data for James Tiberius Kirk of Star Trek fame

-- author: Karsten Hilbert <Karsten.Hilbert@gmx.net>
-- license: GPL v2 or later
-- =============================================
-- force terminate + exit(3) on errors if non-interactive
\set ON_ERROR_STOP 1

-- =============================================
-- service personalia
-- ---------------------------------------------
-- identity, should cascade to name by itself ...
delete from dem.identity where
	gender = 'm'
		and
	cob = 'CA'
		and
	pk in (select pk_identity from dem.v_basic_person where firstnames='James Tiberius' and lastnames='Kirk' and date_trunc('day', dob) = '1931-3-21');

insert into dem.identity (gender, dob, cob, title, pupic)
values ('m', '1931-3-21 12:00 -5:00', 'CA', 'Capt.', 'SFSN:SC937-0176-CEC');

insert into dem.names (id_identity, active, lastnames, firstnames, comment)
values (currval('dem.identity_pk_seq'), true, 'Kirk', 'James Tiberius', 'name of character in Star Trek series');

insert into dem.names (id_identity, active, lastnames, firstnames, comment)
values (currval('dem.identity_pk_seq'), false, 'Kirk', 'James R.', 'the original middle initial was R. as seen in "Where No Man Has Gone Before"');

insert into dem.names (id_identity, active, lastnames, firstnames, comment)
values (currval('dem.identity_pk_seq'), false, 'Shatner', 'William', 'name of actor in real life');

insert into dem.enum_ext_id_types (name, issuer, context)
values ('Starfleet Serial Number', 'Star Fleet Central Staff Office', 'p');

insert into dem.lnk_identity2ext_id (id_identity, external_id, fk_origin)
values (currval('dem.identity_pk_seq'), 'SC937-0176-CEC', currval('dem.enum_ext_id_types_pk_seq'));

-- only works because services are in the same database
insert into clin.xlnk_identity (xfk_identity, pupic)
values (currval('dem.identity_pk_seq'), currval('dem.identity_pk_seq'));

insert into blobs.xlnk_identity (xfk_identity, pupic)
values (currval('dem.identity_pk_seq'), currval('dem.identity_pk_seq'));

-- =============================================
-- service BLOBs
-- =============================================

-- =============================================
-- service historica
-- ---------------------------------------------
-- EMR data

-- put him on some vaccination schedules
delete from clin.lnk_pat2vaccination_course where fk_patient = currval('dem.identity_pk_seq');
-- tetanus
insert into clin.lnk_pat2vaccination_course (fk_patient, fk_course) values (
	currval('dem.identity_pk_seq'),
	(select pk_course from clin.v_vaccination_courses where indication='tetanus' and recommended_by_name_short='SFCVC')
);
-- meningococcus C
insert into clin.lnk_pat2vaccination_course (fk_patient, fk_course) values (
	currval('dem.identity_pk_seq'),
	(select pk_course from clin.v_vaccination_courses where indication='meningococcus C' and recommended_by_name_short='SFCVC')
);
-- hemophilus B
insert into clin.lnk_pat2vaccination_course (fk_patient, fk_course) values (
	currval('dem.identity_pk_seq'),
	(select pk_course from clin.v_vaccination_courses where indication='haemophilus influenzae b' and recommended_by_name_short='SFCVC')
);

-- health issues
delete from clin.health_issue where
	id_patient = currval('dem.identity_pk_seq');

insert into clin.health_issue (id_patient, description, age_noted, laterality)
values (
	currval('dem.identity_pk_seq'),
	'post appendectomy/peritonitis',
	'67 years 11 months',
	'na'
);

insert into clin.health_issue (id_patient, description, laterality)
values (
	currval('dem.identity_pk_seq'),
	'9/2000 extraterrestrial infection',
	'na'
);

-- episode "knife cut"
delete from clin.episode where pk in (
	select pk_episode
	from clin.v_pat_episodes
	where pk_patient = currval('dem.identity_pk_seq')
);

insert into clin.episode (
	description,
	fk_health_issue,
	is_open
) values (
	'postop infected laceration L forearm',
	currval('clin.health_issue_pk_seq'),
	'false'::boolean
);

-- encounter: first, for knife cut ------------------------------------------------
insert into clin.encounter (
	fk_patient,
	fk_location,
	fk_type,
	started,
	last_affirmed,
	reason_for_encounter,
	assessment_of_encounter
) values (
	currval('dem.identity_pk_seq'),
	-1,
	(select pk from clin.encounter_type where description='in surgery'),
	'2000-9-17 17:13',
	'2000-9-17 19:33',
	'bleeding cut forearm L',
	'?contaminated laceration L forearm'
);

-- document of type "patient picture"
insert into blobs.doc_med (patient_id, type, comment, fk_encounter, fk_episode) values (
	currval('dem.identity_pk_seq'),
	(select pk from blobs.doc_type where name='patient photograph'),
	'Captain Kirk pictures',
	currval('clin.encounter_pk_seq'),
	currval('clin.episode_pk_seq')
);

-- image object
set client_encoding = 'UNICODE';
insert into blobs.doc_obj (doc_id, seq_idx, comment, fk_intended_reviewer, data) VALUES (
	currval('blobs.doc_med_pk_seq'),
	1,
	'a small picture of Kirk',
	(select pk_staff from dem.v_staff where firstnames='Leonard Horatio' and lastnames='McCoy' and dob='1920-1-20+2:00'),
	E'GIF89a0\\0000\\000\\325\\000\\000\\377\\377\\377\\275\\234\\234\\224sk\\275\\204s\\326\\275\\265\\224{s\\275\\214{\\245{k\\214cR\\275\\234\\214{ZJ\\255{c\\316\\255\\234\\306\\224{\\245sZ\\234kRcB1\\204R91!\\030\\347\\316\\275\\306\\255\\234cJ9\\265\\204cB)\\030Z9!\\316\\255\\224\\306\\245\\214\\265\\224{sR9\\214cBsZBB1!)\\030\\010\\336\\306\\255\\275\\245\\21491)\\234\\204k\\214sZ\\020\\010\\000B)\\010\\326\\306\\255RB)cZJ\\357\\347\\326RJ9\\214{R\\255\\234kskR\\275\\255{\\214\\204Zsskkkc))!\\234\\234{\\030\\030\\020BJ!\\255\\265\\224\\245\\275\\23419J\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000\\000,\\000\\000\\000\\0000\\0000\\000@\\006\\377@\\204P\\241@\\274*\\220\\012\\347P\\330\\355lP\\223I2\\032\\321\\250\\254jj\\304R\\315X,\\020k&\\003#\\017$\\322\\342\\223Jz\\336#\\247\\223\\306*)"\\217\\274\\3052\\3507\\014\\033.\\013\\007\\003\\033\\006\\015\\014(\\023!\\033\\007\\007\\002)\\022P#S#[\\020\\035\\021\\034N,B\\036\\012\\017\\016\\013{\\026\\016\\204\\011\\032\\011\\006\\253\\015\\255\\255\\003{\\260\\015%)N#\\020:\\271:44\\012\\035\\020\\020\\036\\035\\241\\016}{\\216$\\002%\\241\\006\\003\\276\\010%*P;&\\012%%\\033\\025\\237\\022^2\\2744U\\022 mH\\237\\035%\\242\\204\\016\\030&\\030x\\203\\006!z}\\364\\013\\017\\006\\0364^33/\\0121\\000_\\2340\\021\\314\\003\\004\\014m<D\\030\\326\\241a\\236\\003\\011\\022lh\\364 S\\036\\207(2\\204\\010\\021\\243C\\014\\007.6\\2200\\010\\201\\003\\260\\012\\012^|\\222c\\203F\\033`)\\332\\304\\034\\361\\001\\234\\225p\\022\\244\\2008\\001\\341\\304\\205\\377._j\\355\\370`\\251\\2155Jr>\\240\\024\\226''\\035\\237\\015}\\014D\\214\\310\\252\\025\\003\\002\\011Z\\341c1IW\\225\\004\\0070|\\370 cF\\011\\004\\036.\\230\\260\\301I\\312\\011\\017\\017\\026\\310\\035\\345GC\\210\\011\\004D4s`b\\016\\027]\\272h\\330HH\\004\\201\\251\\001\\257\\0268\\260h!\\021\\001\\002\\00140H\\245A\\303+>\\013\\366\\361;\\221\\202\\204\\210\\0348^\\000\\303\\340\\246\\003\\002\\005\\0250\\014s\\264\\241\\006\\011G\\204\\014\\015h*\\012B\\245.*^\\370\\363\\320BAI\\005\\006Sp\\030\\016\\341\\302\\011\\014\\034\\254\\0118`h\\203\\304\\003\\016.\\016\\357\\350\\302E\\014\\021.\\036\\300\\200Q}\\373v\\017\\303\\337xP\\311\\246\\000\\015\\226\\022$\\200\\273\\222^RK\\3676\\372\\202\\310\\375aL\\015\\025\\025X|\\370}\\222C~\\026/\\304!\\007\\015/\\240\\325\\001(\\027u\\000\\036q\\020\\010g\\315\\003\\012p\\200\\301\\204<A\\000F\\012>]\\020SIo\\200 \\377\\307\\016t\\000\\007\\212\\003\\242\\320\\025U\\002\\031\\210PY\\006,\\242@\\300\\012+\\020\\300@\\006\\033\\0108\\230\\015\\022\\304\\304FJ}=\\201\\222Cy4\\305G!\\023\\321c\\344\\220\\260\\320\\223\\037\\015\\027x0\\202\\016U\\\\\\200\\300l\\036\\354\\220\\302n\\371i\\343\\001J%\\034`\\242s`6@O,|\\034 \\324\\016\\306\\005&\\301\\001\\277\\014\\367 \\211\\016\\024V@\\001$\\240\\245\\232(\\017`p\\302q\\301\\250p\\315 \\032\\224\\260\\003\\010\\340\\214\\001\\330MH\\004S\\204\\000\\246\\360\\261\\212\\227\\321u\\340\\200d\\013tYBC\\0159@\\202\\003\\026,\\300A\\003F\\220!\\003`^\\231QX(\\007\\224\\262XE\\017\\034`\\000\\001\\031\\314\\206X\\003\\226\\211\\271G1\\003\\214\\301\\217n>\\351\\311S\\011\\015&\\241M\\021\\010\\204"@\\001\\216<\\320\\023r\\007\\004\\260At$\\316\\265\\200\\007\\022\\330\\322\\205n\\012\\324\\200C\\0150\\274\\300BI\\022\\236D\\3040\\016\\234\\346\\301\\204\\021\\244+\\377\\351\\003\\357(\\326\\224\\010(l\\373\\302\\015\\212\\002\\027C\\013\\036\\334`\\022r\\303\\371\\252h(\\322\\035\\224n(\\366D\\360F\\007\\034i\\267]w(p\\267]C\\034\\214\\247B\\203\\244\\355\\353+r\\237@\\263\\334#\\010H\\330A\\005%\\264\\320\\202\\\\1dWLu.x\\007\\003p\\237\\020q\\304\\005J\\011\\300\\326\\023P@\\301\\213z7U\\221\\2058)\\360\\023F\\0118|Q\\201\\004\\025\\000t\\300p\\376E\\354\\017\\004/\\234\\2113Q[\\\\q\\205\\015 \\204\\023_\\217\\355\\350\\250\\302\\326*\\260p\\236\\004''%\\332r\\265N\\3300\\202\\022H\\017\\227\\350\\007b\\021%\\201\\031\\276\\036w\\3028\\020x\\221\\202Z/\\251]A\\005\\037\\2320\\302Y\\237\\320\\306\\307\\255\\017 \\320\\020\\002\\203L\\324\\214\\035\\021+@IKc\\005\\373\\206\\012\\347\\015\\310\\002\\313M\\215\\342\\250\\001\\032\\030 \\302\\347"dPY"0\\242PY\\014)T=\\216\\2061\\241\\364\\302\\007\\037\\206\\030\\301\\210\\351\\304\\026\\377\\225\\006\\024\\020@\\001\\005+\\276\\270\\002\\005\\264\\032\\020\\240\\011\\274\\200\\240!B \\237ie\\313\\303dN\\346SE\\216i\\301+\\210m`!/\\036\\230PuLmD\\000\\201-/(H\\014\\234\\242X\\340\\234DE\\036\\202\\330\\230\\364\\034P\\301y\\037(\\300K\\025\\037x\\260\\300\\307O\\2500\\204\\242/8`\\210\\005\\204\\220\\212\\010T\\341\\234Z\\211\\011\\026\\261P\\200\\207v0\\202\\013xeM\\003\\350\\211\\011\\260\\205\\032\\014\\\\\\340\\002\\301\\270\\000\\010\\342\\327\\250A\\014\\240\\031\\244\\360\\003=\\370\\342\\004\\023\\300\\314+\\037\\320\\200\\003J\\002\\001k\\220\\3504\\227\\333Z\\016T\\260\\223\\023p\\240D\\321a\\316\\371(\\200\\002\\012@\\305\\001~\\031\\201\\012\\274b\\203Nx\\257\\205\\305z\\3001\\312u\\270\\003\\330aJl\\032\\010\\326R@\\004\\017 @\\004/x[\\021\\311p(\\033h\\343 \\031#\\221\\243&\\322\\210H\\341\\252X\\016X\\206\\000\\274\\005\\002\\020\\224`\\001\\326+\\\\\\012T \\203Qy\\377e\\0046\\300\\240\\242\\240q\\030\\255@\\207U\\007\\310\\000\\003|\\230*\\350\\200DE\\253XL\\003^\\300\\217~\\220*\\027t`\\001J|\\021\\027B\\0000R\\222\\262\\300F\\022\\020\\000\\006\\204\\216E\\242\\023\\223b\\032\\240\\000:\\356\\252\\012P\\252B\\241\\366f\\016tx\\251\\024\\252\\031\\306\\000D\\307\\200\\011\\310\\322\\017\\266\\022\\205\\001*p\\203}\\370\\003\\004\\022\\200\\231\\006A\\0206m\\360\\321\\024\\216\\020\\200\\002\\2143!w\\374\\221S\\000L\\225b\\024 \\205k\\351\\346\\005\\315,\\032\\012j@1`\\230\\343p\\256L\\246a\\2343\\300\\331\\214\\257Rm\\244\\2065\\3751\\202\\032\\304K\\004%\\000\\317AX\\351\\013"X\\020\\023\\012p@3\\372\\340\\245\\304\\221\\317\\001 \\360\\233$U\\220\\222\\335\\024\\240d$\\260\\015\\277\\016\\342M\\2464\\205\\011gA\\213I\\004\\006\\260ap\\247:$\\340N\\015jP\\002I\\222\\240\\004*\\331\\320\\033$t\\001\\344\\020\\341"\\351\\232\\020\\007\\364\\320\\251\\2120\\204Du.\\260K\\006\\\\P\\202\\030d\\000\\006\\0358\\200\\013z\\003\\214#\\320\\2138z\\302\\240\\025\\273D\\010w9$:\\354\\342@C`\\260\\200\\026\\244\\254;\\013\\333N\\006\\360\\245\\250\\340\\200\\353 {JA\\3066\\306\\311\\000$@\\000\\206{\\303\\013H\\320\\201\\005\\270\\200\\004\\201P\\030T\\267\\203\\264\\361x\\340[\\037(i3\\215\\263\\223\\212)DA\\347RM\\0138p\\215\\030\\244A\\015-(\\031L\\241\\032\\004\\000;'
);
set client_encoding = 'latin1';

-- LMcC review
insert into blobs.reviewed_doc_objs (fk_reviewed_row, fk_reviewer, is_technically_abnormal, clinically_relevant, comment) values (
	currval('blobs.doc_obj_pk_seq'),
	(select pk_staff from dem.v_staff where short_alias='LMcC'),
	false,
	true,
	'looks unwell'
);

-- JB review
insert into blobs.reviewed_doc_objs (fk_reviewed_row, fk_reviewer, is_technically_abnormal, clinically_relevant, comment) values (
	currval('blobs.doc_obj_pk_seq'),
	(select pk_staff from dem.v_staff where short_alias='JB'),
	false,
	false,
	'this is definitely Kirk'
);

insert into clin.operation (
	fk_health_issue,
	fk_encounter,
	clin_where
) values (
	(select pk from clin.health_issue where description = 'post appendectomy/peritonitis'),
	currval('clin.encounter_pk_seq'),
	'Starfleet Central Hospital Ward A-II'
);

-- subjective
insert into clin.clin_narrative (
	clin_when,
	fk_encounter,
	fk_episode,
	narrative,
	soap_cat
) values (
	'2000-9-17 17:16:41',
	currval('clin.encounter_pk_seq'),
	currval('clin.episode_pk_seq'),
	'accid cut himself left forearm -2/24 w/ dirty
blade rescuing self from being tentacled,
extraterrest.envir.',
	's'
);

-- objective
insert into clin.clin_narrative (
	clin_when,
	fk_encounter,
	fk_episode,
	narrative,
	soap_cat
) values (
	'2000-9-17 17:20:59',
	currval('clin.encounter_pk_seq'),
	currval('clin.episode_pk_seq'),
	'left ulnar forearm; 6cm dirty laceration;
skin/sc fat only; musc/tend not injured; no dist sens loss;
pain/redness++; smelly secretion+; no pus',
	'o'
);

-- assessment
insert into clin.clin_narrative (
	clin_when,
	fk_encounter,
	fk_episode,
	narrative,
	soap_cat
) values (
	'2000-9-17 17:21:19',
	currval('clin.encounter_pk_seq'),
	currval('clin.episode_pk_seq'),
	'contam/infected knife cut left arm, ?extraterr. vector, needs ABs/surg/blood',
	'a'
);

-- plan
insert into clin.clin_narrative (
	clin_when,
	fk_encounter,
	fk_episode,
	narrative,
	soap_cat
) values (
	'2000-9-17 17:2',
	currval('clin.encounter_pk_seq'),
	currval('clin.episode_pk_seq'),
	'1) inflamm.screen/std ET serology
2) debridement/loose adapt.; 10ml xylocitin sc; 00-Reprolene
3) Pen 1.5 Mega 1-1-1
4) review +2/7; tomorrow if symptoms/blood screen +ve',
	'p'
);

-- diagnoses
insert into clin.clin_narrative (
	clin_when,
	fk_encounter,
	fk_episode,
	narrative,
	soap_cat
) values (
	'2000-9-17 17:21:19',
	currval('clin.encounter_pk_seq'),
	currval('clin.episode_pk_seq'),
	'?contaminated laceration L forearm',
	'a'
);

insert into clin.clin_diag (
	fk_narrative,
	laterality,
	is_chronic,
	is_active,
	is_definite,
	clinically_relevant
) values (
	currval('clin.clin_narrative_pk_seq'),
	'l',
	false,
	true,
	true,
	true
);

-- codes
select clin.add_coded_term (
	'?contaminated laceration L forearm',
	'T11.1',
	'ICD-10-GM 2004'
);

-- given Td booster shot
insert into clin.vaccination (
	fk_encounter,
	fk_episode,
	narrative,
	fk_patient,
	fk_provider,
	fk_vaccine,
	clin_when,
	site,
	batch_no
) values (
	currval('clin.encounter_pk_seq'),
	currval('clin.episode_pk_seq'),
	'prev booster > 7 yrs',
	currval('dem.identity_pk_seq'),
	(select pk_staff from dem.v_staff where firstnames='Leonard Horatio' and lastnames='McCoy' and dob='1920-1-20+2:00'),
	(select pk from clin.vaccine where trade_name='Tetasorbat (SFCMS)'),
	'2000-9-17',
	'left deltoid muscle',
	'SFCMS#102041A#11'
);


-- blood sample drawn for screen/CRP
insert into clin.lab_request (
	clin_when,
	fk_encounter,
	fk_episode,
	narrative,
	fk_test_org,
	request_id,
	fk_requestor,
	lab_request_id,
	lab_rxd_when,
	results_reported_when,
	request_status,
	is_pending
) values (
	'2000-9-17 17:33',
	currval('clin.encounter_pk_seq'),
	currval('clin.episode_pk_seq'),
	'inflammation screen, possibly extraterrestrial contamination',
	(select pk from clin.test_org where internal_name='Enterprise Main Lab'),
	'EML#SC937-0176-CEC#11',
	(select pk_identity from dem.v_basic_person where firstnames='Leonard Horatio' and lastnames='McCoy' and dob='1920-1-20+2:00'::timestamp),
	'SC937-0176-CEC#15034',
	'2000-9-17 17:40',
	'2000-9-17 18:10',
	'final',
	false
);

-- results reported by lab
-- leukos
insert into clin.test_result (
	clin_when,
	fk_encounter,
	fk_episode,
	fk_type,
	val_num,
	val_unit,
	val_normal_range,
	abnormality_indicator,
	material,
	fk_intended_reviewer
) values (
	'2000-9-17 18:17',
	currval('clin.encounter_pk_seq'),
	currval('clin.episode_pk_seq'),
	(select pk from clin.test_type where code='WBC-EML'),
	'9.5',
	'Gpt/l',
	'4.4-11.3',
	'',
	'EDTA blood',
	(select pk_identity from dem.v_staff where firstnames='Leonard Horatio' and lastnames='McCoy' and dob='1920-1-20+2:00')
);

insert into clin.lnk_result2lab_req(fk_result, fk_request) values (
	currval('clin.test_result_pk_seq'),
	currval('clin.lab_request_pk_seq')
);

-- erys
insert into clin.test_result (
	clin_when,
	fk_encounter,
	fk_episode,
	fk_type,
	val_num,
	val_unit,
	val_normal_range,
	abnormality_indicator,
	material,
	fk_intended_reviewer
) values (
	'2000-9-17 18:17',
	currval('clin.encounter_pk_seq'),
	currval('clin.episode_pk_seq'),
	(select pk from clin.test_type where code='RBC-EML'),
	'4.40',
	'Tpt/l',
	'4.1-5.1',
	'',
	'EDTA blood',
	(select pk_identity from dem.v_staff where firstnames='Leonard Horatio' and lastnames='McCoy' and dob='1920-1-20+2:00')
);

insert into clin.lnk_result2lab_req(fk_result, fk_request) values (
	currval('clin.test_result_pk_seq'),
	currval('clin.lab_request_pk_seq')
);

-- platelets
insert into clin.test_result (
	clin_when,
	fk_encounter,
	fk_episode,
	fk_type,
	val_num,
	val_unit,
	val_normal_range,
	abnormality_indicator,
	material,
	fk_intended_reviewer
) values (
	'2000-9-17 18:17',
	currval('clin.encounter_pk_seq'),
	currval('clin.episode_pk_seq'),
	(select pk from clin.test_type where code='PLT-EML'),
	'282',
	'Gpt/l',
	'150-450',
	'',
	'EDTA blood',
	(select pk_identity from dem.v_staff where firstnames='Leonard Horatio' and lastnames='McCoy' and dob='1920-1-20+2:00')
);

insert into clin.lnk_result2lab_req(fk_result, fk_request) values (
	currval('clin.test_result_pk_seq'),
	currval('clin.lab_request_pk_seq')
);

-- CRP
insert into clin.test_result (
	clin_when,
	fk_encounter,
	fk_episode,
	fk_type,
	val_num,
	val_unit,
	val_normal_range,
	abnormality_indicator,
	material,
	fk_intended_reviewer
) values (
	'2000-9-17 18:23',
	currval('clin.encounter_pk_seq'),
	currval('clin.episode_pk_seq'),
	(select pk from clin.test_type where code='CRP-EML'),
	'17.3',
	'mg/l',
	'0.07-8',
	'++',
	'Serum',
	(select pk_identity from dem.v_staff where firstnames='Leonard Horatio' and lastnames='McCoy' and dob='1920-1-20+2:00')
);

insert into clin.lnk_result2lab_req(fk_result, fk_request) values (
	currval('clin.test_result_pk_seq'),
	currval('clin.lab_request_pk_seq')
);

-- encounter, second for knife cut ------------------------------------------
insert into clin.encounter (
	fk_patient,
	fk_location,
	fk_type,
	started,
	last_affirmed,
	reason_for_encounter,
	assessment_of_encounter
) values (
	currval('dem.identity_pk_seq'),
	-1,
	(select pk from clin.encounter_type where description='in surgery'),
	'2000-9-18 8:13',
	'2000-9-18 8:47',
	'knife cut follow-up, pain/swelling',
	'postop infected laceration L forearm'
);

-- diagnoses
insert into clin.clin_narrative (
	clin_when,
	fk_encounter,
	fk_episode,
	narrative,
	soap_cat
) values (
	'2000-9-18 8:44:19',
	currval('clin.encounter_pk_seq'),
	currval('clin.episode_pk_seq'),
	'postop infected laceration L forearm',
	'a'
);

insert into clin.clin_diag (
	fk_narrative,
	laterality,
	is_chronic,
	is_active,
	is_definite,
	clinically_relevant
) values (
	currval('clin.clin_narrative_pk_seq'),
	'l',
	false,
	true,
	true,
	true
);

-- codes
select clin.add_coded_term (
	'postop infected laceration L forearm',
	'T79.3',
	'ICD-10-GM 2004'
);

select clin.add_coded_term (
	'postop infected laceration L forearm',
	'B97.8!',
	'ICD-10-GM 2004'
);

-- wound infected, penicillin had been prescribed, developed urticaria
insert into clin.allergy (
	fk_encounter,
	fk_episode,
	substance,
	allergene,
	id_type,
	narrative
) values (
	currval('clin.encounter_pk_seq'),
	currval('clin.episode_pk_seq'),
	'Penicillin V Stada',
	'Penicillin',
	1,
	'developed urticaria/dyspnoe this morning, eg. 12h after first tablet'
);

insert into clin.allergy_state (
	fk_patient,
	has_allergy
) values (
	currval('dem.identity_pk_seq'),
	1
);

-- =============================================
-- family history
insert into clin.hx_family_item (
	name_relative,
	dob_relative,	
	condition,
	age_noted,
	age_of_death,
	is_cause_of_death
) values (
	'George Samuel Kirk',
	'1928-7-19+2:00',
	'Denevan neural parasite infection',
	'37 years (2267, Stardate 3287)',
	'37 years',
	true
);

insert into clin.clin_hx_family (
	fk_encounter,
	fk_episode,
	soap_cat,
	narrative,
	fk_hx_family_item
) values (
	currval('clin.encounter_pk_seq'),
	currval('clin.episode_pk_seq'),
	's',
	'brother',
	currval('clin.hx_family_item_pk_seq')
);

insert into clin.lnk_type2item (fk_type, fk_item) values (
	(select pk from clin.clin_item_type where code = 'fHx'),
	currval('clin.clin_root_item_pk_item_seq')
);

-- =============================================
-- went to Vietnam for holidays
insert into blobs.doc_med (
	patient_id,
	type,
	comment,
	ext_ref,
	fk_encounter,
	fk_episode
) values (
	currval('dem.identity_pk_seq'),
	(select pk from blobs.doc_type where name='referral report other'),
	'Vietnam 2003: The Peoples Republic',
	'vietnam-2003-3::1',
	currval('clin.encounter_pk_seq'),
	currval('clin.episode_pk_seq')
);

insert into blobs.doc_desc (
	doc_id,
	text
) values (
	currval('blobs.doc_med_pk_seq'),
	'people'
);

-- need to run the insert on data separately !
insert into blobs.doc_obj (
	doc_id,
	seq_idx,
	comment,
	fk_intended_reviewer,
	data
) values (
	currval('blobs.doc_med_pk_seq'),
	1,
	'Happy schoolgirls enjoying the afternoon sun catching the smile of
	 passers-by at an ancient bridge in the paddy fields near Hue.',
	 (select pk_staff from dem.v_staff where firstnames='Leonard Horatio' and lastnames='McCoy' and dob='1920-1-20+2:00'),
	 'missing'
);

insert into blobs.doc_obj (
	doc_id,
	seq_idx,
	comment,
	fk_intended_reviewer,
	data
) values (
	currval('blobs.doc_med_pk_seq'),
	2,
	'Mekong River Delta Schoolgirls making their way home.',
	(select pk_staff from dem.v_staff where firstnames='Leonard Horatio' and lastnames='McCoy' and dob='1920-1-20+2:00'),
	 'missing'
);

insert into blobs.doc_med (
	patient_id,
	type,
	comment,
	ext_ref,
	fk_encounter,
	fk_episode
) values (
	currval('dem.identity_pk_seq'),
	(select pk from blobs.doc_type where name='referral report other'),
	'Vietnam 2003: Tagwerk',
	'vietnam-2003-3::2',
	currval('clin.encounter_pk_seq'),
	currval('clin.episode_pk_seq')
);

insert into blobs.doc_desc (
	doc_id,
	text
) values (
	currval('blobs.doc_med_pk_seq'),
	'life'
);

-- need to run the insert on data separately !
insert into blobs.doc_obj (
	doc_id,
	seq_idx,
	comment,
	fk_intended_reviewer,
	data
) values (
	currval('blobs.doc_med_pk_seq'),
	1,
	'Perfume pagoda river boating',
	(select pk_staff from dem.v_staff where firstnames='Leonard Horatio' and lastnames='McCoy' and dob='1920-1-20+2:00'),
	 'missing'
);

-- episode "scar pain"
insert into clin.episode (
	description,
	fk_health_issue,
	is_open
) values (
	'scar problems left arm',
	currval('clin.health_issue_pk_seq'),
	'true'::boolean
);


-- =============================================
-- new episode "back pain"
-- =============================================
insert into clin.episode (
	fk_patient,
	description,
	is_open
) values (
	currval('dem.identity_pk_seq'),
	'back pain',
	'true'::boolean
);

-- =============================================
-- a few notices to the provider
-- =============================================
insert into dem.provider_inbox (
	fk_staff,
	fk_inbox_item_type,
	comment,
	data,
	importance
) values (
	(select pk_staff from dem.v_staff where short_alias='LMcC'),
	(select pk_type from dem.v_inbox_item_type where type='FYI'),
	'Mr. Kirk is off to Galactica until 2009',
	'he took along warm socks',
	-1
);

insert into dem.provider_inbox (
	fk_staff,
	fk_inbox_item_type,
	comment,
	importance
) values (
	(select pk_staff from dem.v_staff where short_alias='LMcC'),
	(select pk_type from dem.v_inbox_item_type where type='memo'),
	'Beware of Dr.Jekyll !',
	-1
);

-- =============================================
-- do simple schema revision tracking
select log_script_insertion('$RCSfile: test_data-James_Kirk.sql,v $', '$Revision: 1.81 $');

