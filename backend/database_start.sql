INSERT INTO public.camps(
	camp_id, camp_name, start_date, end_date)
	VALUES (1, 'Robotics', 'July 8, 2024', 'July 12, 2024');
	
INSERT INTO public.camps(
	camp_id, camp_name, start_date, end_date)
	VALUES (2, 'Tennis Level 1', 'July 15, 2024', 'July 19, 2024');
	
INSERT INTO public.camps(
	camp_id, camp_name, start_date, end_date)
	VALUES (3, 'Tennis Level 2', 'July 15, 2024', 'July 19, 2024');

INSERT INTO public.users(
	user_id, email, password, first_name, last_name)
	VALUES (0, 'test@gmail.com', 'testpassword', 'Aiden', 'Ma');

INSERT INTO public.parent_notes(
	pa_note_id, pa_note_date, camp_id, pa_note, pa_note_upd_date, pa_note_upd_by)
	VALUES (1, 'Mar 25, 2024', 1, 'Test parent note', 'Mar 27, 2024', 0);
	
	
INSERT INTO public.incident_notes(
	in_note_id, in_note_date, camp_id, in_note, in_note_upd_date, in_note_upd_by)
	VALUES (1, 'Mar 25, 2024', 1, 'Test incident note', 'Mar 27, 2024', 0);
	
INSERT INTO public.staff_performance_notes(
	st_note_id, st_note_date, camp_id, st_note, st_note_upd_date, st_note_upd_by)
	VALUES (1, 'Mar 25, 2024', 1, 'Test staff performance note', 'Mar 27, 2024', 0);
	
INSERT INTO public.roles(
	role_id, role_name, role_description)
	VALUES (1, 'Supervisor', 'test');
	
INSERT INTO public.camp_user_role(
	user_id, camp_id, role_id)
	VALUES (0, 1, 1);