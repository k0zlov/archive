BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "archive_audit" ADD COLUMN "actorEmail" text NOT NULL DEFAULT ''::text;
ALTER TABLE "archive_audit" ADD COLUMN "module" text NOT NULL DEFAULT ''::text;
ALTER TABLE "archive_audit" ADD COLUMN "beforeJson" text NOT NULL DEFAULT '{}'::text;
ALTER TABLE "archive_audit" ADD COLUMN "afterJson" text NOT NULL DEFAULT '{}'::text;
ALTER TABLE "archive_audit" ADD COLUMN "detailsJson" text NOT NULL DEFAULT '{}'::text;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "archive_document" ADD COLUMN "deletedAt" timestamp without time zone;
ALTER TABLE "archive_document" ADD COLUMN "deletedBy" text;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "archive_import_job" ADD COLUMN "replaceExisting" boolean NOT NULL DEFAULT false;
ALTER TABLE "archive_import_job" ADD COLUMN "sourceNamesJson" text NOT NULL DEFAULT '[]'::text;
ALTER TABLE "archive_import_job" ADD COLUMN "resultJson" text NOT NULL DEFAULT '{}'::text;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "archive_record" ADD COLUMN "deletedAt" timestamp without time zone;
ALTER TABLE "archive_record" ADD COLUMN "deletedBy" text;

--
-- MIGRATION VERSION FOR archive
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('archive', '20261029133516949', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261029133516949', "timestamp" = now();

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
