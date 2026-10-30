BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "archive_presence" (
    "id" bigserial PRIMARY KEY,
    "userId" text NOT NULL,
    "authId" text NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "archive_presence_user_idx" ON "archive_presence" USING btree ("userId");
CREATE INDEX "archive_presence_expiry_idx" ON "archive_presence" USING btree ("expiresAt");


--
-- MIGRATION VERSION FOR archive
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('archive', '20261030132745518-live_presence', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261030132745518-live_presence', "timestamp" = now();

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
