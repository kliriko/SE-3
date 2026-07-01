const characterService = require("../services/characterService");

function list(req, res, next) {
  try {
    const filters = {
      q: req.query.q || "",
      className: req.query.className || "",
      isActive:
        req.query.isActive === "true"
          ? 1
          : req.query.isActive === "false"
          ? 0
          : undefined,
      ownerId: req.query.ownerId ? Number(req.query.ownerId) : undefined,
    };

    const items = characterService.listCharacters(req.session.user, filters);
    return res.json({ items });
  } catch (error) {
    return next(error);
  }
}

function getOne(req, res, next) {
  try {
    const item = characterService.getCharacter(req.session.user, Number(req.params.id));
    return res.json({ item });
  } catch (error) {
    return next(error);
  }
}

function create(req, res, next) {
  try {
    const item = characterService.createCharacter(req.session.user, req.body);
    return res.status(201).json({ item });
  } catch (error) {
    return next(error);
  }
}

function update(req, res, next) {
  try {
    const item = characterService.updateCharacter(req.session.user, Number(req.params.id), req.body);
    return res.json({ item });
  } catch (error) {
    return next(error);
  }
}

function setActivation(req, res, next) {
  try {
    const item = characterService.setCharacterActive(req.session.user, Number(req.params.id), req.body.isActive);
    return res.json({ item });
  } catch (error) {
    return next(error);
  }
}

function remove(req, res, next) {
  try {
    characterService.removeCharacter(req.session.user, Number(req.params.id));
    return res.json({ message: "Deleted" });
  } catch (error) {
    return next(error);
  }
}

module.exports = {
  list,
  getOne,
  create,
  update,
  setActivation,
  remove,
};
