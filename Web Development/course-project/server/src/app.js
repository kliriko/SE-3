const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const session = require("express-session");
const SQLiteStore = require("connect-sqlite3")(session);
const rateLimit = require("express-rate-limit");
const { graphqlHTTP } = require("express-graphql");
const { clientUrl, sessionSecret } = require("./config/env");
const authRoutes = require("./routes/rest/authRoutes");
const characterRoutes = require("./routes/rest/characterRoutes");
const graphqlSchema = require("./graphql/schema");
const { errorMiddleware } = require("./middlewares/errorMiddleware");
const { requireAuth } = require("./middlewares/authMiddleware");
const { subscribe, unsubscribe } = require("./events/characterEvents");

const app = express();

app.use(helmet({ crossOriginResourcePolicy: false }));
app.use(
  cors({
    origin: clientUrl,
    credentials: true,
  })
);
app.use(express.json({ limit: "1mb" }));

app.use(
  rateLimit({
    windowMs: 10 * 60 * 1000,
    limit: 200,
  })
);

app.use(
  session({
    store: new SQLiteStore({
      db: "sessions.sqlite",
      dir: process.cwd(),
    }),
    name: "resource_center_sid",
    secret: sessionSecret,
    resave: false,
    saveUninitialized: false,
    cookie: {
      httpOnly: true,
      maxAge: 24 * 60 * 60 * 1000,
      sameSite: "lax",
    },
  })
);

app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

app.get("/api/events/characters", requireAuth, (req, res) => {
  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache");
  res.setHeader("Connection", "keep-alive");
  res.flushHeaders();

  subscribe(res);
  res.write("event: connected\\ndata: {\"status\":\"connected\"}\\n\\n");

  req.on("close", () => {
    unsubscribe(res);
  });
});

app.use("/api/rest/auth", authRoutes);
app.use("/api/rest/characters", characterRoutes);

app.use(
  "/api/graphql",
  graphqlHTTP((req) => ({
    schema: graphqlSchema,
    graphiql: true,
    context: { req },
  }))
);

app.use(errorMiddleware);

module.exports = app;
