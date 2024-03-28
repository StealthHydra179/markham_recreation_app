CREATE TABLE "users" (
  "user_id" SERIAL PRIMARY KEY,
  "email" VARCHAR(256),
  "password" VARCHAR(64),
  "first_name" VARCHAR(64),
  "last_name" VARCHAR(64)
);

CREATE TABLE "camps" (
  "camp_id" INTEGER PRIMARY KEY,
  "camp_name" VARCHAR(256),
  "start_date" TIMESTAMP,
  "end_date" TIMESTAMP
);

CREATE TABLE "roles" (
  "role_id" INTEGER PRIMARY KEY,
  "role_name" VARCHAR(64),
  "role_description" VARCHAR(256)
);

CREATE TABLE "camp_user_role" (
  "user_id" INTEGER,
  "camp_id" INTEGER,
  "role_id" INTEGER,
  PRIMARY KEY ("user_id", "camp_id")
);

CREATE TABLE "absent" (
  "absent_id" SERIAL PRIMARY KEY,
  "camp_id" INTEGER,
  "camper_first_name" VARCHAR(64),
  "camper_last_name" VARCHAR(64),
  "absent_date" TIMESTAMP,
  "followed_up" BOOLEAN,
  "reason" TEXT,
  "absent_date_modified" TIMESTAMP,
  "absent_upd_by" INTEGER
);

CREATE TABLE "checklist" (
  "camp_id" INTEGER PRIMARY KEY,
  "camper_info_form" BOOLEAN,
  "camper_info_form_upd_by" INTEGER,
  "camper_info_form_upd_date" TIMESTAMP,
  "allergy_medical_info" BOOLEAN,
  "allergy_medical_info_upd_by" INTEGER,
  "allergy_medical_info_upd_date" TIMESTAMP,
  "swim_test_records" BOOLEAN,
  "swim_test_records_upd_by" INTEGER,
  "swim_test_records_upd_date" TIMESTAMP,
  "weekly_plans" BOOLEAN,
  "weekly_plans_upd_by" INTEGER,
  "weekly_plans_upd_date" TIMESTAMP,
  "director_check" BOOLEAN,
  "director_check_upd_by" INTEGER,
  "director_check_upd_date" TIMESTAMP,
  "counsellor_check" BOOLEAN,
  "counsellor_check_upd_by" INTEGER,
  "counsellor_check_upd_date" TIMESTAMP
);

CREATE TABLE "attendance" (
  "attendance_id" SERIAL PRIMARY KEY,
  "camp_id" INTEGER,
  "attendance_date" TIMESTAMP,
  "present" INTEGER,
  "present_upd_by" INTEGER,
  "before_care" INTEGER,
  "before_care_upd_by" INTEGER,
  "after_care" INTEGER,
  "after_care_upd_by" INTEGER
);

CREATE TABLE "equipment_supplies_notes" (
  "equip_id" SERIAL PRIMARY KEY,
  "camp_id" INTEGER,
  "equip_note" TEXT,
  "equip_note_date_modified" TIMESTAMP,
  "equip_note_upd_by" INTEGER
);

CREATE TABLE "message" (
  "message_id" INTEGER PRIMARY KEY,
  "camp_id" INTEGER,
  "message" TEXT,
  "message_upd_by" INTEGER
);

CREATE TABLE "daily_notes" (
  "daily_note_id" INTEGER PRIMARY KEY,
  "daily_note_date" TIMESTAMP,
  "camp_id" INTEGER,
  "daily_note" TEXT,
  "daily_note_upd_by" INTEGER
);

CREATE TABLE "weekly_supervisor_meeting_notes" (
  "s_meet_note_id" INTEGER PRIMARY KEY,
  "s_meet_note_date" TIMESTAMP,
  "camp_id" INTEGER,
  "s_meet_note" TEXT,
  "s_meet_note_upd_by" INTEGER
);

CREATE TABLE "weekly_counsellor_meeting_notes" (
  "c_meet_note_id" INTEGER PRIMARY KEY,
  "c_meet_note_date" TIMESTAMP,
  "camp_id" INTEGER,
  "c_meet_note" TEXT,
  "c_meet_note_upd_by" INTEGER
);

CREATE TABLE "staff_performance_notes" (
  "st_note_id" INTEGER PRIMARY KEY,
  "st_note_date" TIMESTAMP,
  "camp_id" INTEGER,
  "st_note" TEXT,
  "st_note_upd_date" TIMESTAMP,
  "st_note_upd_by" INTEGER
);

CREATE TABLE "parent_notes" (
  "pa_note_id" INTEGER PRIMARY KEY,
  "pa_note_date" TIMESTAMP,
  "camp_id" INTEGER,
  "pa_note" TEXT,
  "pa_note_upd_date" TIMESTAMP,
  "pa_note_upd_by" INTEGER
);

CREATE TABLE "incident_notes" (
  "in_note_id" INTEGER PRIMARY KEY,
  "in_note_date" TIMESTAMP,
  "camp_id" INTEGER,
  "in_note" TEXT,
  "in_note_upd_date" TIMESTAMP,
  "in_note_upd_by" INTEGER
);


ALTER TABLE "camp_user_role" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "camp_user_role" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id");

ALTER TABLE "absent" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id");

ALTER TABLE "absent" ADD FOREIGN KEY ("absent_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "checklist" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id"); 

ALTER TABLE "checklist" ADD FOREIGN KEY ("camper_info_form_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "checklist" ADD FOREIGN KEY ("allergy_medical_info_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "checklist" ADD FOREIGN KEY ("swim_test_records_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "checklist" ADD FOREIGN KEY ("weekly_plans_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "checklist" ADD FOREIGN KEY ("director_check_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "checklist" ADD FOREIGN KEY ("counsellor_check_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "attendance" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id");

ALTER TABLE "attendance" ADD FOREIGN KEY ("present_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "attendance" ADD FOREIGN KEY ("before_care_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "attendance" ADD FOREIGN KEY ("after_care_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "equipment_supplies_notes" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id");

ALTER TABLE "equipment_supplies_notes" ADD FOREIGN KEY ("equip_note_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "message" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id");

ALTER TABLE "message" ADD FOREIGN KEY ("message_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "daily_notes" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id");

ALTER TABLE "daily_notes" ADD FOREIGN KEY ("daily_note_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "weekly_supervisor_meeting_notes" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id");

ALTER TABLE "weekly_supervisor_meeting_notes" ADD FOREIGN KEY ("s_meet_note_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "weekly_counsellor_meeting_notes" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id");

ALTER TABLE "weekly_counsellor_meeting_notes" ADD FOREIGN KEY ("c_meet_note_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "staff_performance_notes" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id");

ALTER TABLE "staff_performance_notes" ADD FOREIGN KEY ("st_note_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "parent_notes" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id");

ALTER TABLE "parent_notes" ADD FOREIGN KEY ("pa_note_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "incident_notes" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id");

ALTER TABLE "incident_notes" ADD FOREIGN KEY ("in_note_upd_by") REFERENCES "users" ("user_id");


ALTER TABLE public.absent OWNER to markham_rec;
ALTER TABLE public.attendance OWNER to markham_rec;
ALTER TABLE public.camp_user_role OWNER to markham_rec;
ALTER TABLE public.camps OWNER to markham_rec;
ALTER TABLE public.checklist OWNER to markham_rec;
ALTER TABLE public.daily_notes OWNER to markham_rec;
ALTER TABLE public.equipment_supplies_notes OWNER to markham_rec;
ALTER TABLE public.incident_notes OWNER to markham_rec;
ALTER TABLE public.message OWNER to markham_rec;
ALTER TABLE public.parent_notes OWNER to markham_rec;
ALTER TABLE public.roles OWNER to markham_rec;
ALTER TABLE public.staff_performance_notes OWNER to markham_rec;
ALTER TABLE public.users OWNER to markham_rec;
ALTER TABLE public.weekly_counsellor_meeting_notes OWNER to markham_rec;
ALTER TABLE public.weekly_supervisor_meeting_notes OWNER to markham_rec;



