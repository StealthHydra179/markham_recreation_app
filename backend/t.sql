ALTER TABLE absent
RENAME TO absence
	
ALTER TABLE absence 
RENAME COLUMN absent_id TO absence_id;

ALTER TABLE absence 
RENAME COLUMN absent_date TO absence_date;	

ALTER TABLE absence 
RENAME COLUMN absent_upd_by TO absence_upd_by;	

ALTER TABLE absence 
RENAME COLUMN absent_date_modified TO absence_upd_date;	

ALTER TABLE attendance
ADD COLUMN present_upd_date TIMESTAMP,
ADD COLUMN before_care_upd_date TIMESTAMP,
ADD COLUMN after_care_upd_date TIMESTAMP


ALTER TABLE camps
RENAME TO camp


ALTER TABLE daily_notes
RENAME TO daily_note

ALTER TABLE daily_note
ADD COLUMN daily_note_upd_date TIMESTAMP

ALTER TABLE equipment_supplies_notes
RENAME TO equipment_note

ALTER TABLE equipment_note
ADD COLUMN equip_note_date TIMESTAMP

ALTER TABLE equipment_note 
RENAME COLUMN equip_note_date_modified TO equip_note_upd_date;	

ALTER TABLE incident_notes
RENAME TO incident_note

ALTER TABLE incident_note
ADD COLUMN in_note_upd_date TIMESTAMP

ALTER TABLE message
RENAME TO app_message 

ALTER TABLE app_message
ADD COLUMN message_date TIMESTAMP

ALTER TABLE app_message
ADD COLUMN message_upd_date TIMESTAMP

ALTER TABLE parent_notes
RENAME TO parent_note 

ALTER TABLE roles
RENAME TO app_role 

ALTER TABLE staff_performance_notes
RENAME TO staff_performance_note

ALTER TABLE staff_performance_note
ADD COLUMN st_note_upd_date TIMESTAMP

ALTER TABLE users
RENAME TO app_user 

ALTER TABLE weekly_counsellor_meeting_notes
RENAME TO weekly_counsellor_meeting_note

ALTER TABLE weekly_counsellor_meeting_note
ADD COLUMN c_meet_upd_date TIMESTAMP

ALTER TABLE weekly_supervisor_meeting_note   
ADD COLUMN s_meet_upd_date TIMESTAMP

ADD COLUMN in_note_upd_date TIMESTAMP

table: absent -> absence
column: absent_id -> absence_id
column: absent_date -> absence_date
column: absent_date_modified -> absence_upd_date
column: absent_upd_by -> absence_upd_by

table: camps -> camp

table: daily_notes -> daily_note
column: daily_note_upd_date

table: equipment_supplies_notes -> equipment_note
column: equip_note_date_modified -> equip_note_upd_date

table: incident_notes -> incident_note

table: message -> app_message
column: add message_date
column: add message_upd_date

table: parent_notes -> parent_note

table: roles -> role

table: staff_performance_notes -> staff_performance_note

table: users -> app_user

table: weekly_counsellor_meeting_notes -> weekly_counsellor_meeting_note

table: weekly_supervisor_meeting_notes -> weekly_supervisor_meeting_note

column: all notes tables: add date and upd_date columns

table attendance
add column: present_upd_date, before_care_upd_date, after_care_upd_date

rename primary key
daily_note_date modified date?
in_note_date
