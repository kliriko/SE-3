const path = require("path");
const dotenv = require("dotenv");

dotenv.config({ path: path.resolve(process.cwd(), ".env") });

module.exports = {
  port: Number(process.env.PORT || 4000),
  clientUrl: process.env.CLIENT_URL || "http://localhost:5173",
  sessionSecret: process.env.SESSION_SECRET || "dev-session-secret",
  dbPath: process.env.DB_PATH || path.resolve(process.cwd(), "data.sqlite"),
  appUrl: process.env.APP_URL || "http://localhost:4000",
  dmEmail: process.env.DM_EMAIL || "dm@resource-center.local",
  dmPassword: process.env.DM_PASSWORD || "dm12345",
};
