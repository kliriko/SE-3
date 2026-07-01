const charactersRepository = require("../repositories/charactersRepository");
const { emitCharacterUpdated } = require("../events/characterEvents");
const { characterSchema, activationSchema } = require("../utils/validators");

function ensureValidCharacterPayload(payload) {
  const parsed = characterSchema.safeParse(payload);
  if (!parsed.success) {
    throw new Error("Invalid input data");
  }
  return parsed.data;
}

function ensureValidActivationPayload(isActive) {
  const parsed = activationSchema.safeParse({ isActive });
  if (!parsed.success) {
    throw new Error("Invalid input data");
  }
  return parsed.data.isActive;
}

function formatCharacter(row) {
  return {
    id: row.id,
    name: row.name,
    className: row.class_name,
    race: row.race,
    level: row.level,
    alignment: row.alignment,
    str: row.str_score,
    dex: row.dex_score,
    con: row.con_score,
    int: row.int_score,
    wis: row.wis_score,
    cha: row.cha_score,
    ac: row.ac,
    ms: row.ms,
    hp: row.hp,
    ownerId: row.owner_id,
    ownerName: `${row.first_name} ${row.last_name}`,
    isActive: Boolean(row.is_active),
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

function ensureCanAccess(user, character) {
  if (user.role === "dm") return;
  if (character.owner_id !== user.id) {
    throw new Error("Forbidden");
  }
}

function listCharacters(user, filters) {
  const scopedFilters = user.role === "dm" ? filters : { ...filters, ownerId: user.id };
  return charactersRepository.listCharacters(scopedFilters).map(formatCharacter);
}

function getCharacter(user, id) {
  const entity = charactersRepository.getCharacterById(id);
  if (!entity) {
    throw new Error("Character not found");
  }

  ensureCanAccess(user, entity);
  return formatCharacter(entity);
}

function createCharacter(user, payload) {
  const validPayload = ensureValidCharacterPayload(payload);
  const entity = charactersRepository.createCharacter({
    ...validPayload,
    ownerId: user.role === "dm" && validPayload.ownerId ? validPayload.ownerId : user.id,
    isActive: validPayload.isActive ?? true,
  });
  const character = formatCharacter(entity);
  emitCharacterUpdated({ type: "created", characterId: character.id });
  return character;
}

function updateCharacter(user, id, payload) {
  const current = charactersRepository.getCharacterById(id);
  if (!current) {
    throw new Error("Character not found");
  }

  if (!current.is_active) {
    throw new Error("Cannot edit inactive character");
  }

  ensureCanAccess(user, current);
  const validPayload = ensureValidCharacterPayload({
    ...payload,
    isActive: typeof payload.isActive === "boolean" ? payload.isActive : Boolean(current.is_active),
  });

  const updated = charactersRepository.updateCharacter(id, {
    name: validPayload.name,
    className: validPayload.className,
    race: validPayload.race,
    level: validPayload.level,
    alignment: validPayload.alignment,
    str: validPayload.str,
    dex: validPayload.dex,
    con: validPayload.con,
    int: validPayload.int,
    wis: validPayload.wis,
    cha: validPayload.cha,
    ac: validPayload.ac,
    ms: validPayload.ms,
    hp: validPayload.hp,
    isActive: validPayload.isActive,
  });

  const character = formatCharacter(updated);
  emitCharacterUpdated({ type: "updated", characterId: character.id });
  return character;
}

function setCharacterActive(user, id, isActive) {
  if (user.role !== "dm") {
    throw new Error("Forbidden");
  }

  const current = charactersRepository.getCharacterById(id);
  if (!current) {
    throw new Error("Character not found");
  }

  const validIsActive = ensureValidActivationPayload(isActive);
  const updated = charactersRepository.setCharacterActive(id, validIsActive);
  const character = formatCharacter(updated);
  emitCharacterUpdated({ type: "activation-changed", characterId: character.id });
  return character;
}

function removeCharacter(user, id) {
  const current = charactersRepository.getCharacterById(id);
  if (!current) {
    throw new Error("Character not found");
  }

  ensureCanAccess(user, current);
  charactersRepository.deleteCharacter(id);
  emitCharacterUpdated({ type: "deleted", characterId: id });
}

module.exports = {
  listCharacters,
  getCharacter,
  createCharacter,
  updateCharacter,
  setCharacterActive,
  removeCharacter,
};
