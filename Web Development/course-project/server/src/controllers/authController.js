const authService = require("../services/authService");

async function register(req, res, next) {
  try {
    const result = await authService.register(req.body);
    return res.status(201).json({
      message: "Registration successful. Verify your email.",
      verifyLink: result.verifyLink,
      user: result.user,
      debugMailPayload: result.transportMessage,
    });
  } catch (error) {
    return next(error);
  }
}

async function verifyEmail(req, res, next) {
  try {
    const { token } = req.query;
    const user = await authService.verifyEmail(token);
    return res.json({ message: "Email verified", user });
  } catch (error) {
    return next(error);
  }
}

async function login(req, res, next) {
  try {
    const user = await authService.login(req.body);
    req.session.user = user;
    return res.json({ message: "Logged in", user });
  } catch (error) {
    return next(error);
  }
}

function logout(req, res, next) {
  req.session.destroy((err) => {
    if (err) return next(err);
    res.clearCookie("resource_center_sid");
    return res.json({ message: "Logged out" });
  });
}

function me(req, res) {
  return res.json({ user: req.session.user || null });
}

module.exports = {
  register,
  verifyEmail,
  login,
  logout,
  me,
};
