BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "archive_audit" (
    "id" bigserial PRIMARY KEY,
    "actorId" text NOT NULL,
    "action" text NOT NULL,
    "target" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "archive_document" (
    "id" bigserial PRIMARY KEY,
    "title" text NOT NULL,
    "fileName" text NOT NULL,
    "kind" text NOT NULL,
    "year" bigint NOT NULL,
    "content" bytea NOT NULL,
    "createdBy" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "archive_member" (
    "id" bigserial PRIMARY KEY,
    "userId" text NOT NULL,
    "email" text NOT NULL,
    "displayName" text NOT NULL,
    "role" text NOT NULL DEFAULT 'pending'::text,
    "managementAccess" boolean NOT NULL DEFAULT false,
    "courtAccess" boolean NOT NULL DEFAULT false,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "archive_member_user_idx" ON "archive_member" USING btree ("userId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "archive_record" (
    "id" bigserial PRIMARY KEY,
    "module" text NOT NULL,
    "identityKey" text NOT NULL,
    "reference" text NOT NULL,
    "proceeding" text NOT NULL,
    "valuesJson" text NOT NULL,
    "version" bigint NOT NULL DEFAULT 1,
    "createdBy" text NOT NULL,
    "updatedBy" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "archive_record_identity_idx" ON "archive_record" USING btree ("identityKey");
CREATE INDEX "archive_record_module_idx" ON "archive_record" USING btree ("module");


--
-- MIGRATION VERSION FOR archive
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('archive', '20261029113303397', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261029113303397', "timestamp" = now();

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
