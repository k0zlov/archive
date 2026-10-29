BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "archive_member" ADD COLUMN "login" text;
ALTER TABLE "archive_member" ADD COLUMN "passwordChangeRequired" boolean NOT NULL DEFAULT false;
-- Preserve user IDs, password hashes, memberships and audit ownership.
-- Reserve a collision-free fallback namespace before deriving readable logins.
UPDATE "archive_member" SET "login" = 'user-' || "id"::text;
WITH candidates AS (
  SELECT "id", lower(split_part("email", '@', 1)) AS candidate,
         count(*) OVER (PARTITION BY lower(split_part("email", '@', 1))) AS copies
  FROM "archive_member"
)
UPDATE "archive_member" AS member
SET "login" = candidates.candidate
FROM candidates
WHERE member."id" = candidates."id"
  AND candidates.copies = 1
  AND candidates.candidate ~ '^[a-z0-9][a-z0-9._-]{2,63}$'
  AND candidates.candidate !~ '^user-[0-9]+$';

CREATE UNIQUE INDEX "archive_member_login_idx" ON "archive_member" USING btree ("login");

--
-- MIGRATION VERSION FOR archive
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('archive', '20261029202326913-username_login', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261029202326913-username_login', "timestamp" = now();

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
