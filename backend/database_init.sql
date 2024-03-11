CREATE TABLE "users" (
  "user_id" SERIAL PRIMARY KEY,
  "email" VARCHAR(256),
  "password" VARCHAR(64),
  "first_name" VARCHAR(64),
  "last_name" VARCHAR(64)
);

CREATE TABLE "camp_user_role" (
  "user_id" int,
  "camp_id" int,
  "role" int,
  PRIMARY KEY ("user_id", "camp_id")
);

CREATE TABLE "camps" (
  "camp_id" INTEGER PRIMARY KEY,
  "name" VARCHAR(256),
  "start_date" TIMESTAMP,
  "end_date" TIMESTAMP
);

CREATE TABLE "absent" (
  "absent_id" SERIAL PRIMARY KEY,
  "camp_id" INTEGER,
  "camper_name" VARCHAR(128),
  "date" TIMESTAMP,
  "followed_up" BOOLEAN,
  "reason" TEXT,
  "date_modified" TIMESTAMP,
  "upd_by" INTEGER
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

CREATE TABLE "equipment_supplies_notes" (
  "equip_id" SERIAL PRIMARY KEY,
  "date_modified" TIMESTAMP,
  "camp_id" INTEGER,
  "note" TEXT,
  "upd_by" INTEGER
);

ALTER TABLE "camps" ADD FOREIGN KEY ("camp_id") REFERENCES "checklist" ("camp_id");

ALTER TABLE "absent" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id");

-- ALTER TABLE "message" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id");

-- ALTER TABLE "notes" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id");

-- ALTER TABLE "staff_performance_notes" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id");

ALTER TABLE "checklist" ADD FOREIGN KEY ("camper_info_form_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "checklist" ADD FOREIGN KEY ("allergy_medical_info_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "checklist" ADD FOREIGN KEY ("swim_test_records_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "checklist" ADD FOREIGN KEY ("weekly_plans_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "checklist" ADD FOREIGN KEY ("director_check_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "checklist" ADD FOREIGN KEY ("counsellor_check_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "absent" ADD FOREIGN KEY ("upd_by") REFERENCES "users" ("user_id");

-- ALTER TABLE "notes" ADD FOREIGN KEY ("by") REFERENCES "users" ("user_id");

-- ALTER TABLE "message" ADD FOREIGN KEY ("message_upd_by") REFERENCES "users" ("user_id");

-- ALTER TABLE "staff_performance_notes" ADD FOREIGN KEY ("by") REFERENCES "users" ("user_id");

ALTER TABLE "equipment_supplies_notes" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id");

ALTER TABLE "equipment_supplies_notes" ADD FOREIGN KEY ("upd_by") REFERENCES "users" ("user_id");

-- ALTER TABLE "parent_notes" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id");

-- ALTER TABLE "parent_notes" ADD FOREIGN KEY ("by") REFERENCES "users" ("user_id");

-- ALTER TABLE "incident_notes" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id");

-- ALTER TABLE "incident_notes" ADD FOREIGN KEY ("by") REFERENCES "users" ("user_id");

-- ALTER TABLE "attendance" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id");

-- ALTER TABLE "attendance" ADD FOREIGN KEY ("present_upd_by") REFERENCES "users" ("user_id");

-- ALTER TABLE "attendance" ADD FOREIGN KEY ("before_care_upd_by") REFERENCES "users" ("user_id");

-- ALTER TABLE "attendance" ADD FOREIGN KEY ("after_care_upd_by") REFERENCES "users" ("user_id");

ALTER TABLE "camp_user_role" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("user_id");

ALTER TABLE "camp_user_role" ADD FOREIGN KEY ("camp_id") REFERENCES "camps" ("camp_id");
