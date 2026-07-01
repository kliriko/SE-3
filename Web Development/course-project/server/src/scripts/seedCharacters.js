const bcrypt = require("bcryptjs");
const db = require("../config/db");
const { dmEmail } = require("../config/env");

const seedUserEmail = "player@resource-center.local";
const seedUserPassword = "player123";

function ensureUser({ email, firstName, lastName, role, isVerified, password }) {
  const existing = db.prepare("SELECT id FROM users WHERE email = ?").get(email);
  if (existing) {
    return existing.id;
  }

  const passwordHash = bcrypt.hashSync(password, 10);
  const result = db
    .prepare(
      `INSERT INTO users (email, password_hash, first_name, last_name, role, is_verified)
       VALUES (?, ?, ?, ?, ?, ?)`
    )
    .run(email, passwordHash, firstName, lastName, role, isVerified ? 1 : 0);

  return result.lastInsertRowid;
}

function main() {
  const dm = db.prepare("SELECT id FROM users WHERE email = ?").get(dmEmail);
  if (!dm) {
    throw new Error(`DM user not found for email: ${dmEmail}`);
  }

  const userId = ensureUser({
    email: seedUserEmail,
    firstName: "Test",
    lastName: "Player",
    role: "user",
    isVerified: true,
    password: seedUserPassword,
  });

  const characters = [
    {
      name: "Aria Sunblade",
      className: "Fighter",
      race: "Human",
      level: 4,
      alignment: "Lawful Good",
      str: 16,
      dex: 12,
      con: 14,
      int: 10,
      wis: 11,
      cha: 13,
      ac: 17,
      ms: 30,
      hp: 38,
      ownerId: dm.id,
      isActive: 1,
    },
    {
      name: "Borin Ironfist",
      className: "Cleric",
      race: "Dwarf",
      level: 5,
      alignment: "Neutral Good",
      str: 14,
      dex: 10,
      con: 16,
      int: 11,
      wis: 17,
      cha: 12,
      ac: 18,
      ms: 25,
      hp: 44,
      ownerId: dm.id,
      isActive: 1,
    },
    {
      name: "Nyx Whisper",
      className: "Rogue",
      race: "Elf",
      level: 3,
      alignment: "Chaotic Neutral",
      str: 9,
      dex: 17,
      con: 12,
      int: 14,
      wis: 10,
      cha: 15,
      ac: 15,
      ms: 35,
      hp: 24,
      ownerId: userId,
      isActive: 1,
    },
    {
      name: "Thalia Emberwind",
      className: "Wizard",
      race: "Tiefling",
      level: 6,
      alignment: "Neutral",
      str: 8,
      dex: 14,
      con: 12,
      int: 18,
      wis: 13,
      cha: 12,
      ac: 13,
      ms: 30,
      hp: 31,
      ownerId: userId,
      isActive: 0,
    },
    {
      name: "Grom Stonehide",
      className: "Barbarian",
      race: "Half-Orc",
      level: 5,
      alignment: "Chaotic Good",
      str: 18,
      dex: 13,
      con: 17,
      int: 8,
      wis: 10,
      cha: 9,
      ac: 15,
      ms: 40,
      hp: 52,
      ownerId: dm.id,
      isActive: 0,
    },
    {
      name: "Elowen Marsh",
      className: "Druid",
      race: "Wood Elf",
      level: 4,
      alignment: "True Neutral",
      str: 10,
      dex: 14,
      con: 13,
      int: 12,
      wis: 16,
      cha: 11,
      ac: 14,
      ms: 30,
      hp: 33,
      ownerId: userId,
      isActive: 1,
    },
  ];

  const seedNames = characters.map((item) => item.name);

  const seed = db.transaction(() => {
    const placeholders = seedNames.map(() => "?").join(", ");
    db.prepare(`DELETE FROM characters WHERE name IN (${placeholders})`).run(...seedNames);

    const insert = db.prepare(
      `INSERT INTO characters (
        name, class_name, race, level, alignment,
        str_score, dex_score, con_score, int_score, wis_score, cha_score,
        ac, ms, hp, owner_id, is_active, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)`
    );

    for (const item of characters) {
      insert.run(
        item.name,
        item.className,
        item.race,
        item.level,
        item.alignment,
        item.str,
        item.dex,
        item.con,
        item.int,
        item.wis,
        item.cha,
        item.ac,
        item.ms,
        item.hp,
        item.ownerId,
        item.isActive
      );
    }
  });

  seed();

  const total = db.prepare("SELECT COUNT(*) AS count FROM characters").get();

  console.log("Seed complete.");
  console.log(`Inserted test characters: ${characters.length}`);
  console.log(`Total characters in DB: ${total.count}`);
  console.log(`DM login: ${dmEmail}`);
  console.log(`Test user login: ${seedUserEmail}`);
  console.log(`Test user password: ${seedUserPassword}`);
}

main();
