CREATE TABLE "parent_notes" (
    "pa_note_id" SERIAL PRIMARY KEY,
    "pa_note_date" TIMESTAMP,
    "camp_id" INTEGER,
    "pa_note" TEXT,
    "pa_note_upd_date" TIMESTAMP,
    "pa_note_upd_by" INTEGER
);