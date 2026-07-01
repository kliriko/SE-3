const express = require("express");
const authController = require("../../controllers/authController");
const { validateBody } = require("../../middlewares/validationMiddleware");
const { loginSchema, registerSchema } = require("../../utils/validators");

const router = express.Router();

router.post("/register", validateBody(registerSchema), authController.register);
router.get("/verify-email", authController.verifyEmail);
router.post("/login", validateBody(loginSchema), authController.login);
router.post("/logout", authController.logout);
router.get("/me", authController.me);

module.exports = router;
