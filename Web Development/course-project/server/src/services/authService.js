const bcrypt = require("bcryptjs");
const crypto = require("crypto");
const usersRepository = require("../repositories/usersRepository");
const { sendVerificationEmail } = require("./emailService");
const { appUrl } = require("../config/env");

function sanitizeUser(user) {
  if (!user) return null;
  return {
    id: user.id,
    email: user.email,
    firstName: user.first_name,
    lastName: user.last_name,
    role: user.role,
    isVerified: Boolean(user.is_verified),
  };
}

async function register(payload) {
  const existing = usersRepository.findUserByEmail(payload.email);
  if (existing) {
    throw new Error("Email already in use");
  }

  const passwordHash = await bcrypt.hash(payload.password, 10);
  const verificationToken = crypto.randomBytes(24).toString("hex");

  const user = usersRepository.createUser({
    email: payload.email,
    passwordHash,
    firstName: payload.firstName,
    lastName: payload.lastName,
    role: "user",
    verificationToken,
  });

  const verifyLink = `${appUrl}/api/rest/auth/verify-email?token=${verificationToken}`;
  const transportMessage = await sendVerificationEmail({ to: payload.email, link: verifyLink });

  return {
    user: sanitizeUser(user),
    verifyLink,
    transportMessage,
  };
}

async function verifyEmail(token) {
  const user = usersRepository.findUserByVerificationToken(token);
  if (!user) {
    throw new Error("Invalid verification token");
  }

  usersRepository.verifyUser(user.id);
  const updated = usersRepository.findUserById(user.id);
  return sanitizeUser(updated);
}

async function login({ email, password }) {
  const user = usersRepository.findUserByEmail(email);
  if (!user) {
    throw new Error("Invalid credentials");
  }

  const isValidPassword = await bcrypt.compare(password, user.password_hash);
  if (!isValidPassword) {
    throw new Error("Invalid credentials");
  }

  if (!user.is_verified) {
    throw new Error("Email is not verified");
  }

  return sanitizeUser(user);
}

function getCurrentUser(id) {
  const user = usersRepository.findUserById(id);
  return sanitizeUser(user);
}

module.exports = {
  register,
  verifyEmail,
  login,
  getCurrentUser,
};
