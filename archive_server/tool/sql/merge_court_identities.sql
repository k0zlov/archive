-- Preserve every original card while grouping existing court cards by case number.
-- This transformation is also tested against legacy keys on a separate test database.
LOCK TABLE archive_record IN SHARE ROW EXCLUSIVE MODE;
CREATE TEMP TABLE archive_identity_originals ON COMMIT DROP AS
  SELECT * FROM archive_record WHERE module = 'court' AND "deletedAt" IS NULL;
UPDATE archive_record SET "identityKey" = 'migration:' || id
  WHERE id IN (SELECT id FROM archive_identity_originals);
DO $archive_identity$
DECLARE
  original RECORD;
  target RECORD;
  incoming jsonb;
  combined jsonb;
  item RECORD;
  identity text;
  next_reference text;
  merged_lines text;
  before_snapshot jsonb;
  after_snapshot jsonb;
BEGIN
  FOR original IN SELECT * FROM archive_identity_originals ORDER BY id LOOP
    incoming := original."valuesJson"::jsonb;
    IF NOT incoming ? 'participantDetails' AND NULLIF(btrim(incoming->>'participants'), '') IS NOT NULL THEN
      SELECT jsonb_agg(jsonb_build_object('name', btrim(name), 'role', '', 'proceeding', COALESCE(incoming->>'proceedingNumber', '')) ORDER BY ordinal)
        INTO combined FROM regexp_split_to_table(incoming->>'participants', E'[;\n\r]+') WITH ORDINALITY parts(name, ordinal) WHERE btrim(name) <> '';
      incoming := incoming || jsonb_build_object('participantDetails', combined::text);
    END IF;
    next_reference := COALESCE(NULLIF(btrim(incoming->>'caseNumber'), ''), incoming->>'proceedingNumber', '');
    identity := CASE WHEN NULLIF(btrim(incoming->>'caseNumber'), '') IS NOT NULL
      THEN 'court:case:' ELSE 'court:proceeding:' END || lower(regexp_replace(next_reference, '\s+', '', 'g'));
    SELECT * INTO target FROM archive_record WHERE "identityKey" = identity AND "deletedAt" IS NULL;
    IF NOT FOUND THEN
      UPDATE archive_record SET "identityKey" = identity, reference = next_reference, "valuesJson" = incoming::text,
        version = version + 1, "updatedAt" = CURRENT_TIMESTAMP, "updatedBy" = 'system'
        WHERE id = original.id;
      before_snapshot := jsonb_build_object('id', original.id, 'module', 'court', 'version', original.version,
        'values', incoming, 'updatedAt', original."updatedAt", 'deletedAt', NULL);
      after_snapshot := before_snapshot || jsonb_build_object('version', original.version + 1, 'updatedAt', CURRENT_TIMESTAMP);
      INSERT INTO archive_audit ("actorId", "actorEmail", action, target, module, "beforeJson", "afterJson", "detailsJson", "createdAt")
        VALUES ('system', '', 'record.identity-migration', original.id::text, 'court', before_snapshot::text,
          after_snapshot::text, '{}', CURRENT_TIMESTAMP);
    ELSE
      combined := target."valuesJson"::jsonb;
      before_snapshot := jsonb_build_object('id', target.id, 'module', 'court', 'version', target.version,
        'values', combined, 'updatedAt', target."updatedAt", 'deletedAt', NULL);
      FOR item IN SELECT key, value FROM jsonb_each_text(incoming) LOOP
        IF item.key = 'participantDetails' THEN
          SELECT jsonb_agg(value ORDER BY position) INTO merged_lines FROM (
            SELECT DISTINCT ON (lower(value->>'name'), lower(value->>'role'), lower(value->>'proceeding')) value, ordinal AS position
            FROM jsonb_array_elements(COALESCE((combined->>'participantDetails')::jsonb, '[]'::jsonb) || item.value::jsonb) WITH ORDINALITY entries(value, ordinal)
            ORDER BY lower(value->>'name'), lower(value->>'role'), lower(value->>'proceeding'), ordinal
          ) people;
          combined := jsonb_set(combined, ARRAY[item.key], to_jsonb(merged_lines));
        ELSIF item.key IN ('participants', 'proceedingNumber') THEN
          SELECT string_agg(value, E'\n' ORDER BY position) INTO merged_lines FROM (
            SELECT DISTINCT ON (lower(btrim(part))) btrim(part) AS value, ordinal AS position
            FROM regexp_split_to_table(COALESCE(combined->>item.key, '') || E'\n' || item.value, E'[;\n\r]+')
              WITH ORDINALITY AS parts(part, ordinal)
            WHERE btrim(part) <> '' ORDER BY lower(btrim(part)), ordinal
          ) unique_lines;
          combined := jsonb_set(combined, ARRAY[item.key], to_jsonb(COALESCE(merged_lines, '')));
        ELSIF btrim(COALESCE(combined->>item.key, '')) = '' AND btrim(item.value) <> '' THEN
          combined := jsonb_set(combined, ARRAY[item.key], to_jsonb(item.value));
        END IF;
      END LOOP;
      UPDATE archive_record SET "valuesJson" = combined::text, proceeding = COALESCE(combined->>'proceedingNumber', ''),
        version = version + 1, "updatedAt" = CURRENT_TIMESTAMP, "updatedBy" = 'system' WHERE id = target.id;
      after_snapshot := before_snapshot || jsonb_build_object('version', target.version + 1, 'values', combined, 'updatedAt', CURRENT_TIMESTAMP);
      INSERT INTO archive_audit ("actorId", "actorEmail", action, target, module, "beforeJson", "afterJson", "detailsJson", "createdAt")
        VALUES ('system', '', 'record.merge', target.id::text, 'court', before_snapshot::text,
          after_snapshot::text, jsonb_build_object('sourceId', original.id)::text, CURRENT_TIMESTAMP);
      UPDATE archive_record SET "identityKey" = 'deleted:' || id || ':' || original."identityKey",
        "deletedAt" = CURRENT_TIMESTAMP, "deletedBy" = 'system', version = version + 1,
        "updatedAt" = CURRENT_TIMESTAMP, "updatedBy" = 'system' WHERE id = original.id;
      before_snapshot := jsonb_build_object('id', original.id, 'module', 'court', 'version', original.version,
        'values', incoming, 'updatedAt', original."updatedAt", 'deletedAt', NULL);
      after_snapshot := before_snapshot || jsonb_build_object('version', original.version + 1, 'deletedAt', CURRENT_TIMESTAMP, 'updatedAt', CURRENT_TIMESTAMP);
      INSERT INTO archive_audit ("actorId", "actorEmail", action, target, module, "beforeJson", "afterJson", "detailsJson", "createdAt")
        VALUES ('system', '', 'record.merge', original.id::text, 'court', before_snapshot::text,
          after_snapshot::text, jsonb_build_object('mergedInto', target.id)::text, CURRENT_TIMESTAMP);
    END IF;
  END LOOP;
END
$archive_identity$;
