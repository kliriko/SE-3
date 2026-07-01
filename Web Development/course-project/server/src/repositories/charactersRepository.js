const db = require("../config/db");

function listCharacters({ q, className, isActive, ownerId }) {
  const clauses = [];
  const params = [];

  if (q) {
    clauses.push("(c.name LIKE ? OR c.race LIKE ? OR c.class_name LIKE ? OR c.alignment LIKE ?)");
    params.push(`%${q}%`, `%${q}%`, `%${q}%`, `%${q}%`);
  }

  if (className) {
    clauses.push("c.class_name = ?");
    params.push(className);
  }

  if (typeof isActive === "number") {
    clauses.push("c.is_active = ?");
    params.push(isActive);
  }

  if (ownerId) {
    clauses.push("c.owner_id = ?");
    params.push(ownerId);
  }

  const where = clauses.length ? `WHERE ${clauses.join(" AND ")}` : "";
  const sql = `
    SELECT c.*, u.first_name, u.last_name
    FROM characters c
    JOIN users u ON u.id = c.owner_id
    ${where}
    ORDER BY c.updated_at DESC
  `;

  return db.prepare(sql).all(...params);
}

function getCharacterById(id) {
  return db
    .prepare(
      `SELECT c.*, u.first_name, u.last_name
       FROM characters c
       JOIN users u ON u.id = c.owner_id
       WHERE c.id = ?`
    )
    .get(id);
}

function createCharacter({ name, className, race, level, alignment, str, dex, con, int, wis, cha, ac, ms, hp, ownerId, isActive }) {
  const result = db
    .prepare(
      `INSERT INTO characters (
        name, class_name, race, level, alignment,
        str_score, dex_score, con_score, int_score, wis_score, cha_score,
        ac, ms, hp, owner_id, is_active, updated_at
      )
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)`
    )
    .run(
      name,
      className,
      race,
      level,
      alignment || "",
      str,
      dex,
      con,
      int,
      wis,
      cha,
      ac,
      ms,
      hp,
      ownerId,
      isActive ? 1 : 0
    );

  return getCharacterById(result.lastInsertRowid);
}

function updateCharacter(id, payload) {
  db.prepare(
    `UPDATE characters
     SET name = ?, class_name = ?, race = ?, level = ?, alignment = ?,
         str_score = ?, dex_score = ?, con_score = ?, int_score = ?, wis_score = ?, cha_score = ?,
         ac = ?, ms = ?, hp = ?, is_active = ?, updated_at = CURRENT_TIMESTAMP
     WHERE id = ?`
  ).run(
    payload.name,
    payload.className,
    payload.race,
    payload.level,
    payload.alignment || "",
    payload.str,
    payload.dex,
    payload.con,
    payload.int,
    payload.wis,
    payload.cha,
    payload.ac,
    payload.ms,
    payload.hp,
    payload.isActive ? 1 : 0,
    id
  );

  return getCharacterById(id);
}

function setCharacterActive(id, isActive) {
  db.prepare("UPDATE characters SET is_active = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?").run(isActive ? 1 : 0, id);
  return getCharacterById(id);
}

function deleteCharacter(id) {
  db.prepare("DELETE FROM characters WHERE id = ?").run(id);
}

module.exports = {
  listCharacters,
  getCharacterById,
  createCharacter,
  updateCharacter,
  setCharacterActive,
  deleteCharacter,
};
