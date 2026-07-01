const db = require("../config/db");

function createUser({ email, passwordHash, firstName, lastName, role, verificationToken }) {
  const result = db
    .prepare(
      `INSERT INTO users (email, password_hash, first_name, last_name, role, verification_token)
       VALUES (?, ?, ?, ?, ?, ?)`
    )
    .run(email, passwordHash, firstName, lastName, role, verificationToken);

  return findUserById(result.lastInsertRowid);
}

function findUserByEmail(email) {
  return db.prepare("SELECT * FROM users WHERE email = ?").get(email);
}

function findUserByVerificationToken(token) {
  return db.prepare("SELECT * FROM users WHERE verification_token = ?").get(token);
}

function verifyUser(userId) {
  db.prepare("UPDATE users SET is_verified = 1, verification_token = NULL WHERE id = ?").run(userId);
}

function findUserById(id) {
  return db.prepare("SELECT * FROM users WHERE id = ?").get(id);
}

module.exports = {
  createUser,
  findUserByEmail,
  findUserByVerificationToken,
  verifyUser,
  findUserById,
};
