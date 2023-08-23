-- ==============================================================
-- GNUmed database schema change script
--
-- License: GPL v2 or later
-- Author: Karsten Hilbert
-- 
-- ==============================================================
\set ON_ERROR_STOP 1
set check_function_bodies to 'on';

--set default_transaction_read_only to off;

-- --------------------------------------------------------------
\unset ON_ERROR_STOP
drop function clin.trf_notify_reviewer_of_review_change() cascade;
\set ON_ERROR_STOP 1


create function clin.trf_notify_reviewer_of_review_change()
	returns trigger
	language 'plpgsql'
	as '
declare
	_pk_patient integer;
	_pk_type integer;
begin
	-- disallow change of referenced row
	-- for cleanliness this really *should* be in another trigger
	if NEW.fk_reviewed_row <> OLD.fk_reviewed_row then
		raise exception ''Attaching an existing review to another test result is not allowed (fk_reviewed_row change).'';
		return NEW;
	end if;

	-- change of last reviewer ?
	if NEW.fk_reviewer = OLD.fk_reviewer then
		return NEW;
	end if;

	-- review change ?
	if (NEW.is_technically_abnormal <> OLD.is_technically_abnormal) or
	   (NEW.clinically_relevant <> OLD.clinically_relevant) then

		-- find patient for test result
		select pk_patient into _pk_patient
			from clin.v_test_results
			where pk_test_result = OLD.fk_reviewed_row;

		-- find inbox item type
		select pk_type into _pk_type
			from dem.v_inbox_item_type where
			type = ''results review change'';
		-- create it if necessary
		if not found then
			insert into dem.inbox_item_type (
				fk_inbox_item_category,
				description
			) values (
				(select pk from dem.item_inbox_category where description = ''clinical''),
				''results review change''
			);
			select pk_type into _pk_type
				from dem.v_inbox_item_type where
				type = ''results review change'';
		end if;

		-- already notified ?
		perform 1 from dem.message_inbox where
			fk_staff = OLD.fk_reviewer
			and fk_inbox_item_type = _pk_type
			and ufk_context = ARRAY[_pk_patient];
		-- nope, so notify now
		if not found then
			insert into dem.message_inbox (
				fk_staff, fk_inbox_item_type, comment, ufk_context
			) values (
				OLD.fk_reviewer,
				_pk_type,
				(select
					_(''results review changed for patient'') || '' ['' || vpb.lastnames || '', '' || vbp.firstnames || '']''
					from dem.v_basic_person vbp
					where vpb.pk_identity = _pk_patient
				),
				ARRAY[_pk_patient]
			);
		end if;
	end if;

	return NEW;
end;';


create trigger tr_notify_reviewer_of_review_change
	before update on clin.reviewed_test_results
	for each row execute procedure clin.trf_notify_reviewer_of_review_change()
;

-- --------------------------------------------------------------
select gm.log_script_insertion('$RCSfile: v15-clin-reviewed_test_results-dynamic.sql,v $', '$Revision: 1.1 $');

-- ==============================================================
