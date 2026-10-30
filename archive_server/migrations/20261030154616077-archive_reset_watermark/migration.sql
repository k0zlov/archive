BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "archive_sync_state" (
    "id" bigserial PRIMARY KEY,
    "resetCursor" bigint NOT NULL DEFAULT 0
);


--
-- MIGRATION VERSION FOR archive
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('archive', '20261030154616077-archive_reset_watermark', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261030154616077-archive_reset_watermark', "timestamp" = now();

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
