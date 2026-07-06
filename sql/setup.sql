-- setup.sql — Mentova Chat PostgreSQL Schema
-- Acc_423 — Mentova Web Chat, text-only milestone.
--
-- Six tables: node_fact, chat_log, mentor_account, mentor_session,
-- review_queue, audit_log, plus a schema_version stamp.
--
-- Run this file once to create the production database schema.
-- Each future change raises the schema_version number by one.


-- J.1: node_fact — every word and meaning Mentova holds.
CREATE TABLE node_fact (
  id            BIGSERIAL PRIMARY KEY,
  fact          TEXT        NOT NULL,
  subject       TEXT,
  predicate     TEXT,
  object        TEXT,
  source        TEXT        NOT NULL,
  source_detail TEXT,
  session_id    TEXT,
  turn          INTEGER,
  concreteness  TEXT,
  confidence    REAL,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_node_fact_subject   ON node_fact (subject);

CREATE INDEX idx_node_fact_predicate ON node_fact (predicate);

CREATE INDEX idx_node_fact_object    ON node_fact (object);

CREATE INDEX idx_node_fact_source    ON node_fact (source);


-- J.2: chat_log — every conversation on both tiers.
CREATE TABLE chat_log (
  id          BIGSERIAL PRIMARY KEY,
  session_id  TEXT        NOT NULL,
  tier        TEXT        NOT NULL,
  speaker     TEXT        NOT NULL,
  message     TEXT        NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_chat_log_session ON chat_log (session_id, created_at);


-- J.3: mentor_account — one row per registered mentor.
CREATE TABLE mentor_account (
  id             BIGSERIAL PRIMARY KEY,
  username       TEXT        NOT NULL UNIQUE,
  password_hash  TEXT        NOT NULL,
  active         BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_login_at  TIMESTAMPTZ
);


-- J.4: mentor_session — live sessions for signed-in mentors.
CREATE TABLE mentor_session (
  id          BIGSERIAL PRIMARY KEY,
  mentor_id   BIGINT      NOT NULL REFERENCES mentor_account (id),
  token_hash  TEXT        NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at  TIMESTAMPTZ NOT NULL,
  revoked     BOOLEAN     NOT NULL DEFAULT FALSE
);

CREATE INDEX idx_mentor_session_token ON mentor_session (token_hash);


-- J.5: review_queue — proposed teachings awaiting approval.
CREATE TABLE review_queue (
  id             BIGSERIAL PRIMARY KEY,
  proposed_fact  TEXT        NOT NULL,
  mentor_id      BIGINT      REFERENCES mentor_account (id),
  session_id     TEXT,
  status         TEXT        NOT NULL DEFAULT 'pending',
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  decided_at     TIMESTAMPTZ,
  decided_by     BIGINT      REFERENCES mentor_account (id)
);


-- J.6: audit_log — record of every significant event.
CREATE TABLE audit_log (
  id          BIGSERIAL PRIMARY KEY,
  event       TEXT        NOT NULL,
  detail      TEXT,
  actor       TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- J.7: schema_version — version stamp for safe future migrations.
CREATE TABLE schema_version (
  version     INTEGER     NOT NULL,
  applied_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Insert the initial schema version.
INSERT INTO schema_version (version) VALUES (1);
