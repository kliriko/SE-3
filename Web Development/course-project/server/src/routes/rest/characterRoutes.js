const express = require("express");
const charactersController = require("../../controllers/charactersController");
const { validateBody } = require("../../middlewares/validationMiddleware");
const { requireAuth, requireDm } = require("../../middlewares/authMiddleware");
const { activationSchema, characterSchema } = require("../../utils/validators");

const router = express.Router();

router.use(requireAuth);
router.get("/", charactersController.list);
router.get("/:id", charactersController.getOne);
router.post("/", validateBody(characterSchema), charactersController.create);
router.put("/:id", validateBody(characterSchema), charactersController.update);
router.patch("/:id/activation", requireDm, validateBody(activationSchema), charactersController.setActivation);
router.delete("/:id", charactersController.remove);

module.exports = router;
