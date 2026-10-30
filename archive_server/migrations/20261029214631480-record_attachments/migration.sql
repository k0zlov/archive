BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "archive_attachment" (
    "id" bigserial PRIMARY KEY,
    "recordId" bigint NOT NULL,
    "fileName" text NOT NULL,
    "byteLength" bigint NOT NULL,
    "uploadedBytes" bigint NOT NULL DEFAULT 0,
    "chunkCount" bigint NOT NULL DEFAULT 0,
    "status" text NOT NULL DEFAULT 'uploading'::text,
    "createdBy" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deletedAt" timestamp without time zone,
    "deletedBy" text
);

-- Indexes
CREATE INDEX "archive_attachment_record_idx" ON "archive_attachment" USING btree ("recordId", "status", "deletedAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "archive_attachment_chunk" (
    "id" bigserial PRIMARY KEY,
    "attachmentId" bigint NOT NULL,
    "chunkIndex" bigint NOT NULL,
    "content" bytea NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "archive_attachment_chunk_idx" ON "archive_attachment_chunk" USING btree ("attachmentId", "chunkIndex");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "archive_attachment"
    ADD CONSTRAINT "archive_attachment_fk_0"
    FOREIGN KEY("recordId")
    REFERENCES "archive_record"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "archive_attachment_chunk"
    ADD CONSTRAINT "archive_attachment_chunk_fk_0"
    FOREIGN KEY("attachmentId")
    REFERENCES "archive_attachment"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR archive
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('archive', '20261029214631480-record_attachments', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261029214631480-record_attachments', "timestamp" = now();

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
