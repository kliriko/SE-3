function errorMiddleware(err, req, res, next) {
  if (res.headersSent) {
    return next(err);
  }

  const message = err.message || "Internal server error";
  if (message === "Forbidden") {
    return res.status(403).json({ message });
  }

  if (message.includes("not found") || message.includes("Invalid")) {
    return res.status(400).json({ message });
  }

  return res.status(500).json({ message: "Internal server error" });
}

module.exports = {
  errorMiddleware,
};
