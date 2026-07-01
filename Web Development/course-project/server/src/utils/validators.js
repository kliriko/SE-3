const { z } = require("zod");

const registerSchema = z.object({
  firstName: z.string().min(1).max(50),
  lastName: z.string().min(1).max(50),
  email: z.string().email(),
  password: z.string().min(6).max(100),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6).max(100),
});

const characterSchema = z.object({
  name: z.string().min(1).max(100),
  className: z.string().min(1).max(100),
  race: z.string().min(1).max(100),
  level: z.number().int().min(1).max(20),
  alignment: z.string().max(100).optional().default(""),
  str: z.number().int().min(1).max(30),
  dex: z.number().int().min(1).max(30),
  con: z.number().int().min(1).max(30),
  int: z.number().int().min(1).max(30),
  wis: z.number().int().min(1).max(30),
  cha: z.number().int().min(1).max(30),
  ac: z.number().int().min(1).max(40),
  ms: z.number().int().min(0).max(120),
  hp: z.number().int().min(1).max(999),
  ownerId: z.number().int().positive().optional(),
  isActive: z.boolean().optional().default(true),
});

const activationSchema = z.object({
  isActive: z.boolean(),
});

module.exports = {
  registerSchema,
  loginSchema,
  characterSchema,
  activationSchema,
};
