function requireAuth(req, res, next) {
  if (!req.session.user) {
    return res.status(401).json({ message: "Unauthorized" });
  }
  return next();
}

function requireDm(req, res, next) {
  if (!req.session.user || req.session.user.role !== "dm") {
    return res.status(403).json({ message: "Forbidden" });
  }
  return next();
}

module.exports = {
  requireAuth,
  requireDm,
};
