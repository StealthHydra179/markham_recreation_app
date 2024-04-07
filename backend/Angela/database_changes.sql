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



ALTER TABLE equipment_supplies_notes
RENAME TO equipment_note

ALTER TABLE equipment_note 
RENAME COLUMN equip_note_date_modified TO equip_note_upd_date;	


table: absent -> absence
column: absent_id -> absence_id
column: absent_date -> absence_date
column: absent_date_modified -> absence_upd_date
column: absent_upd_by -> absence_upd_by

table: equipment_supplies_notes -> equipment_note
column: equip_note_date_modified -> equip_note_upd_date
