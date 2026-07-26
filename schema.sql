-- ============================================================
-- Uzbek Telegram Test Bot — D1 (SQLite) schema
-- ============================================================

CREATE TABLE IF NOT EXISTS users (
  telegram_id     INTEGER PRIMARY KEY,
  first_name      TEXT,
  last_name       TEXT,
  father_name     TEXT,
  region          TEXT,
  level           TEXT,          -- 'maktab' | 'talaba'
  grade           TEXT,          -- '5', '11', '1-kurs' ...
  registered      INTEGER DEFAULT 0,
  state           TEXT,          -- FSM current step
  state_data      TEXT,          -- JSON blob with in-progress data
  is_whitelisted  INTEGER DEFAULT 0,
  created_at      TEXT DEFAULT (datetime('now')),
  last_seen       TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS admins (
  telegram_id  INTEGER PRIMARY KEY,
  role         TEXT DEFAULT 'teacher',  -- 'owner' | 'teacher'
  name         TEXT,
  added_by     INTEGER,
  added_at     TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS channels (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  chat_id   TEXT NOT NULL,
  title     TEXT,
  type      TEXT NOT NULL,   -- 'required' | 'base' | 'results'
  added_by  INTEGER,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS tests (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  code          TEXT UNIQUE NOT NULL,
  subject       TEXT,
  file_id       TEXT,
  file_type     TEXT,          -- 'photo' | 'document'
  answer_key    TEXT,          -- e.g. "ABCDABCD"
  points        TEXT,          -- JSON array of per-question points, e.g. [1,1,2,1]
  start_time    TEXT,          -- ISO datetime
  end_time      TEXT,          -- ISO datetime
  is_closed     INTEGER DEFAULT 0,
  created_by    INTEGER,
  created_at    TEXT DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS submissions (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  test_id        INTEGER NOT NULL,
  telegram_id    INTEGER NOT NULL,
  answers        TEXT,
  correct_count  INTEGER,
  total_count    INTEGER,
  score          REAL,
  max_score      REAL,
  submitted_at   TEXT DEFAULT (datetime('now')),
  reminder_sent  INTEGER DEFAULT 0,
  UNIQUE(test_id, telegram_id)
);

CREATE TABLE IF NOT EXISTS settings (
  key    TEXT PRIMARY KEY,
  value  TEXT
);

-- default settings
INSERT OR IGNORE INTO settings (key, value) VALUES ('maintenance', '0');

CREATE INDEX IF NOT EXISTS idx_submissions_test ON submissions(test_id);
CREATE INDEX IF NOT EXISTS idx_tests_code ON tests(code);
