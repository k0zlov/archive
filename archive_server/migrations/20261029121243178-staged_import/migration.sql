BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "archive_import_job" (
    "id" bigserial PRIMARY KEY,
    "userId" text NOT NULL,
    "module" text NOT NULL,
    "status" text NOT NULL DEFAULT 'open'::text,
    "receivedRows" bigint NOT NULL DEFAULT 0,
    "lastOffset" bigint NOT NULL DEFAULT -1,
    "lastBatchJson" text NOT NULL DEFAULT ''::text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "archive_import_row" (
    "id" bigserial PRIMARY KEY,
    "jobId" bigint NOT NULL,
    "identityKey" text NOT NULL,
    "reference" text NOT NULL,
    "proceeding" text NOT NULL,
    "valuesJson" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "archive_import_row_identity_idx" ON "archive_import_row" USING btree ("jobId", "identityKey");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "archive_import_row"
    ADD CONSTRAINT "archive_import_row_fk_0"
    FOREIGN KEY("jobId")
    REFERENCES "archive_import_job"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR archive
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('archive', '20261029121243178-staged_import', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261029121243178-staged_import', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
