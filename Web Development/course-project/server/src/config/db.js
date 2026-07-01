const Database = require("better-sqlite3");
const bcrypt = require("bcryptjs");
const { dbPath, dmEmail, dmPassword } = require("./env");

const db = new Database(dbPath);

db.pragma("journal_mode = WAL");

db.exec(`
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'user',
    is_verified INTEGER NOT NULL DEFAULT 0,
    verification_token TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS characters (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    class_name TEXT NOT NULL,
    race TEXT NOT NULL,
    level INTEGER NOT NULL,
    alignment TEXT,
    str_score INTEGER NOT NULL DEFAULT 10,
    dex_score INTEGER NOT NULL DEFAULT 10,
    con_score INTEGER NOT NULL DEFAULT 10,
    int_score INTEGER NOT NULL DEFAULT 10,
    wis_score INTEGER NOT NULL DEFAULT 10,
    cha_score INTEGER NOT NULL DEFAULT 10,
    ac INTEGER NOT NULL DEFAULT 10,
    ms INTEGER NOT NULL DEFAULT 30,
    hp INTEGER NOT NULL DEFAULT 10,
    owner_id INTEGER NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(owner_id) REFERENCES users(id)
  );
`);

function ensureCharacterColumn(name, definition) {
  const columns = db.prepare("PRAGMA table_info(characters)").all();
  const exists = columns.some((column) => column.name === name);
  if (!exists) {
    db.exec(`ALTER TABLE characters ADD COLUMN ${name} ${definition}`);
  }
}

ensureCharacterColumn("str_score", "INTEGER NOT NULL DEFAULT 10");
ensureCharacterColumn("dex_score", "INTEGER NOT NULL DEFAULT 10");
ensureCharacterColumn("con_score", "INTEGER NOT NULL DEFAULT 10");
ensureCharacterColumn("int_score", "INTEGER NOT NULL DEFAULT 10");
ensureCharacterColumn("wis_score", "INTEGER NOT NULL DEFAULT 10");
ensureCharacterColumn("cha_score", "INTEGER NOT NULL DEFAULT 10");
ensureCharacterColumn("ac", "INTEGER NOT NULL DEFAULT 10");
ensureCharacterColumn("ms", "INTEGER NOT NULL DEFAULT 30");
ensureCharacterColumn("hp", "INTEGER NOT NULL DEFAULT 10");

const existingDm = db.prepare("SELECT id FROM users WHERE email = ?").get(dmEmail);
if (!existingDm) {
  const passwordHash = bcrypt.hashSync(dmPassword, 10);
  db.prepare(
    `INSERT INTO users (email, password_hash, first_name, last_name, role, is_verified)
     VALUES (?, ?, 'Dungeon', 'Master', 'dm', 1)`
  ).run(dmEmail, passwordHash);
}

module.exports = db;
