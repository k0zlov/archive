# Flutter & Serverpod project

This project is a Flutter app (frontend) backed by a Serverpod server (backend). Always build the app's backend with Serverpod.

The user starts the server and Flutter app with `serverpod start`. There is no need to check if the server is running: make the changes and call the `serverpod` MCP tools as needed. If the server is not running, an informative error message will be received from the MCP server. Then STOP and ask the user to start it. NEVER start the server yourself. The Flutter app is started along with it, or can be launched from the MCP tool `spawn_flutter_app`.

While running, `serverpod start` watches for file changes to run incremental code generation and hot reload both the server and the Flutter app.

Calling `serverpod generate` directly is not needed, but might be useful to troubleshoot when an incremental generation fails.

ALWAYS use the MCP server instead of the command line. Use the MCP server to:

- `create_migration` and `apply_migrations` for database (after you change data models).
- `create_repair_migration` if the database has drifted out of sync with the migrations.
- `tail_server_logs` to read logs from the server.
- `tail_flutter_logs` to read the raw stdout/stderr of the Flutter app.
- `hot_reload` / `hot_restart` to reload or restart the server and the Flutter app. ALWAYS call `hot_restart` after doing changes in the Flutter app that may not work with normal hot reload (which is automatically applied).
- `spawn_flutter_app` to start a Flutter app declared under `serverpod: flutter_apps:` in the server `pubspec.yaml`.
- `get_flutter_app_dtd` (Dart tooling daemon) for connecting to the app through the `dart` MCP.

NEVER edit generated code. The server's `lib/src/generated/` directory and the whole `archive_client` package are rewritten by the code generator. Change the `.spy.yaml` models, the endpoints, or `lib/server.dart` instead.

Migrations are a narrow exception: the `migration.sql` of a generated migration MAY be edited by hand when the generated SQL would lose data — to add a data transformation, or to reach a destructive change through non-destructive steps. Never touch the other files in the migration directory, and keep the schema the SQL ends up with identical to `definition.sql` — new databases are created from that file and never run `migration.sql`.

Only when the server cannot be started at all, fall back to the CLI in the server package:

- `serverpod generate` to regenerate the client and the generated server code.
- `serverpod create-migration` after changing a model with a `table` (add `--force` for destructive changes). It only writes the migration; `serverpod start` applies pending migrations when it boots the server.

Tests need no Docker. `config/test.yaml` sets `database.dataPath`, so Serverpod starts and manages the test database (an embedded PostgreSQL) itself, and the project's `docker-compose.yaml` is not used for it. Just run `dart test` in the server package.

Checklist after doing changes, in this order:

- `dart analyze` (CLI)
- `dart format` (CLI)
- `create_migration` and `apply_migrations` (MCP - only if necessary)
- Do `serverpod` MCP `hot_restart` if required (hot reload is done automatically). Will also hot restart Flutter app
- Run tests, if applicable (`dart test` in the server package)
- Check `serverpod` MCP `tail_server_logs` and `tail_flutter_logs` for any issues.

If the user asks you to test the app:

1. Use `get_flutter_app_dtd` (`serverpod` MCP) to get the Flutter app's DTD
2. Pass the DTD to `connect_dart_tooling_daemon` (`dart` MCP) to connect to the app
3. Use `flutter_driver` (`dart` MCP) to navigate through the app

The app is launched from `archive_flutter/lib/driver.dart`, which starts the Flutter driver extension with text entry emulation turned off so the app stays usable by hand. To let the driver type, set `enableTextEntryEmulation: true` there and `hot_restart` the app.

## Archive application

Archive is a Ukrainian-language DESKTOP archive application with a dark green left sidebar. The Serverpod runner launches the `desktop` companion on `device: macos`, not a browser. Preserve this target unless the user requests another desktop OS.

- `archive_shared/lib/archive_schema.dart` defines the Ukrainian field schema (the public archive_shared.dart file re-exports it; the backend imports archive_schema.dart directly), calendar validation, card identity keys and permission rules shared by the server and Flutter.
- The management documentation and court case modules support manually entered, versioned cards. The fields follow the supplied archive architecture workbook.
- `ArchiveEndpoint` requires login and checks the database-backed member role and module permissions on every request. New users are pending; readers can read, editors can write in permitted modules, administrators can manage other users. Blocked users cannot read. An administrator cannot change their own access through this panel.
- Existing administrator identities and password hashes are preserved when migrating to usernames. The migration derives unique lowercase logins from legacy email local parts, using user-ID fallbacks for collisions. `archiveBootstrapAdminEmail`/`ARCHIVE_ADMIN_EMAIL` remains a legacy-only bootstrap path for existing email identities; username registration ALWAYS creates pending members and must never promote a user based on a chosen login. Fresh deployments require server-side initial administrator provisioning. Never put account credentials or bootstrap secrets in Flutter or source control.
- Authentication uses LoginEndpoint (username/password login and registration), AccountEndpoint (self-service password change and administrator reset), and official Serverpod JWT refresh/session storage. The credential adapter reuses the official EmailIdp Argon2 password hashing and persistent failed-login limiter; new accounts use opaque UUID@archive.invalid identifiers internally, with no mailbox, email endpoint, email delivery or verification codes. Legacy credentials keep their original internal identifier. Logins are case-insensitive, 3–64 ASCII letters/digits/dot/underscore/hyphen. Passwords are 8–256 characters. Password resets generate a random temporary password, revoke tokens and force a password change; no secrets are written into audit events. All archive operations reject passwordChangeRequired members, and online caches are purged until the password changes. Sessions and existing memberships must retain their user IDs.
- Import accepts `.xlsx` with headers in row 1, sheet selection, explicit column mapping, validation and preview. There is NO artificial total row, cell or workbook-size limit. Desktop parsing/validation run in a background isolate. Transfer uses byte-bounded batches, server-only staging tables and one final atomic upsert transaction with complete before/after audit events. Do not replace this with independently committed batches or reinstate the 500-row restriction. Progress, cancellation, idempotent append/commit and response-loss recovery are supported. Court identity is ONLY caseNumber (mandatory). Missing case numbers are counted and skipped during imports. Matching identities merge participant tuples (name, role, proceeding). Other nonempty values fill blanks by default, with an explicit overwrite option. The entire import dialog accepts desktop drag-and-drop of multiple .xlsx files (desktop_drop); macOS security-scoped access is released after reading. Calendar/format errors still block imports, but chronology inconsistencies are counted as non-blocking warnings and preserve the source dates. Several workbooks have independent reverse mappings (app field to Excel column) and automatic top summary validation. Do not reintroduce per-row duplicate warnings. Formula cells must first be replaced by values in Excel. `WorkbookService` uses `archive` and `xml`; the `excel` package is incompatible with Serverpod's `archive` dependency version.
- Management nomenclatures are uploaded Word documents stored in the Serverpod database and opened with the default desktop application. These documents are limited to 5 MiB. `NomenclatureDialog` owns its controllers; never dispose controllers immediately after awaiting `showDialog`, since its closing animation has not necessarily finished yet.
- macOS uses the app's private legacy Keychain through `MacOsOptions(usesDataProtectionKeychain: false)`, as recommended by flutter_secure_storage for apps that do not need cross-app Keychain Sharing. It does not require a sharing entitlement or a provisioning profile. Keep authentication tokens in Keychain, never in the data cache.
- Inventory lists filter cards marked for inventory by manually specified long-term or permanent retention, with Excel export. Automatic category-based retention calculations are explicitly deferred by the user; do not invent legal retention rules.
- The related-case search button has been removed at the user’s request. Participant name, role and proceeding are stored together in validated participantDetails JSON within the card values; participants and proceedingNumber remain human-readable summaries. Never discard associations when merging or exporting. Deletions are soft and versioned, with undo and administrator audit recovery.
- Offline access is read-only. The last complete authorized snapshot is stored separately for each server/account. Native platforms use the Drift ORM SQLite database in the application support directory (local_database.dart and generated local_database.g.dart). Keep account isolation, atomic snapshot transactions and purge on permission revocation. Generate Drift code with build_runner; never edit it manually. Legacy JSON snapshots migrate once. Web fallback uses browser storage. Logout clears the cache, including after outstanding refreshes. All accessible nomenclature documents are downloaded in advance; admin snapshots include members and the audit journal. Authentication tokens are excluded from the database. Browser-storage capacity failures are shown in the UI. Revoked module access is purged when the server is next reachable.
- The card list reads 50-row pages from Drift, with a composite account/module/order index and Unicode search text. Keep search and export over the full archive, preserve offline access, and reset to page 1 when filters change. Native ORM snapshot processing and migrations run in background isolates; never move full JSON/ORM batches onto the UI isolate. Single-card saves update one local row and do not force an immediate full archive refresh. `recordRevision` and the append-only audit cursor avoid repeated full downloads. Unchanged native snapshots update only profile/sync metadata; never rewrite every local row just to change a timestamp. `ArchiveActivity` feeds a short text-only status in the top-right header through `ArchiveStatusText`; do not add synchronization progress bars, byte counts or network metrics. Status changes must not rebuild the card list or change editor layout. The sidebar brand is «Архів». Import field mappings are grouped in inline sections matching the card, never tabs. Editors own a clamped scroll controller and align section fields to the left.
- The Flutter data layer is under `lib/data`, views and state under `lib/ui`. `ArchiveController` can be injected into `ArchiveShell` for UI tests. Manrope and its OFL license are bundled to avoid font downloads offline.
- Tests cover server permissions, version conflicts, atomic imports, related searches, workbook mapping/date handling, cache isolation/revocation/logout races, responsive layouts and disabled offline editing.
