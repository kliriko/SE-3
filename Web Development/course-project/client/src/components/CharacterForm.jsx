import { useEffect, useState } from "react";

const initial = {
  name: "",
  className: "",
  race: "",
  level: 1,
  alignment: "",
  str: 10,
  dex: 10,
  con: 10,
  int: 10,
  wis: 10,
  cha: 10,
  ac: 10,
  ms: 30,
  hp: 10,
  isActive: true,
};

export default function CharacterForm({ isOpen, selected, onSubmit, onCancel, canEditOwner, owners }) {
  const [form, setForm] = useState(initial);
  const [error, setError] = useState("");

  useEffect(() => {
    if (selected) {
      setForm(selected);
    } else {
      setForm(initial);
    }
    setError("");
  }, [selected]);

  const validate = () => {
    if (!form.name || !form.className || !form.race) {
      return "Name, class and race are required";
    }
    if (!Number.isInteger(Number(form.level)) || Number(form.level) < 1 || Number(form.level) > 20) {
      return "Level must be between 1 and 20";
    }
    const stats = ["str", "dex", "con", "int", "wis", "cha"];
    for (const stat of stats) {
      const value = Number(form[stat]);
      if (!Number.isInteger(value) || value < 1 || value > 30) {
        return "All stats must be integers between 1 and 30";
      }
    }
    if (!Number.isInteger(Number(form.ac)) || Number(form.ac) < 1 || Number(form.ac) > 40) {
      return "AC must be between 1 and 40";
    }
    if (!Number.isInteger(Number(form.ms)) || Number(form.ms) < 0 || Number(form.ms) > 120) {
      return "MS must be between 0 and 120";
    }
    if (!Number.isInteger(Number(form.hp)) || Number(form.hp) < 1 || Number(form.hp) > 999) {
      return "HP must be between 1 and 999";
    }
    return "";
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    const validationError = validate();
    if (validationError) {
      setError(validationError);
      return;
    }

    setError("");
    await onSubmit({
      ...form,
      level: Number(form.level),
      str: Number(form.str),
      dex: Number(form.dex),
      con: Number(form.con),
      int: Number(form.int),
      wis: Number(form.wis),
      cha: Number(form.cha),
      ac: Number(form.ac),
      ms: Number(form.ms),
      hp: Number(form.hp),
      ownerId: form.ownerId ? Number(form.ownerId) : undefined,
    });
  };

  if (!isOpen) {
    return null;
  }

  return (
    <div className="popup-backdrop" onClick={onCancel}>
      <form className="card p-3 popup-card" onSubmit={handleSubmit} onClick={(event) => event.stopPropagation()}>
        <div className="d-flex justify-content-between align-items-start gap-2">
          <div>
            <div className="small text-uppercase fw-semibold text-muted">Character Sheet</div>
            <h5 className="mt-1 mb-0">{selected?.id ? "Edit character" : "Create new character"}</h5>
          </div>
          <button className="btn btn-sm btn-outline-secondary" type="button" onClick={onCancel}>Close</button>
        </div>

        <div className="row g-2 mt-1">
          <div className="col-md-6">
            <input
              className="form-control"
              placeholder="Name"
              value={form.name}
              onChange={(e) => setForm((prev) => ({ ...prev, name: e.target.value }))}
            />
          </div>
          <div className="col-md-6">
            <input
              className="form-control"
              placeholder="Class"
              value={form.className}
              onChange={(e) => setForm((prev) => ({ ...prev, className: e.target.value }))}
            />
          </div>
          <div className="col-md-6">
            <input
              className="form-control"
              placeholder="Race"
              value={form.race}
              onChange={(e) => setForm((prev) => ({ ...prev, race: e.target.value }))}
            />
          </div>
          <div className="col-md-6">
            <input
              className="form-control"
              placeholder="Level"
              type="number"
              min="1"
              max="20"
              value={form.level}
              onChange={(e) => setForm((prev) => ({ ...prev, level: e.target.value }))}
            />
          </div>
          <div className="col-12">
            <input
              className="form-control"
              placeholder="Alignment"
              value={form.alignment || ""}
              onChange={(e) => setForm((prev) => ({ ...prev, alignment: e.target.value }))}
            />
          </div>

          <div className="col-12 mt-2">
            <div className="small text-uppercase fw-semibold text-muted mb-2">Ability Scores</div>
            <div className="row g-2">
              {[
                ["str", "STR"],
                ["dex", "DEX"],
                ["con", "CON"],
                ["int", "INT"],
                ["wis", "WIS"],
                ["cha", "CHA"],
              ].map(([key, label]) => (
                <div className="col-4 col-md-2" key={key}>
                  <label className="form-label mb-1 small">{label}</label>
                  <input
                    className="form-control"
                    type="number"
                    min="1"
                    max="30"
                    value={form[key]}
                    onChange={(e) => setForm((prev) => ({ ...prev, [key]: e.target.value }))}
                  />
                </div>
              ))}
            </div>
          </div>

          <div className="col-12">
            <div className="row g-2">
              <div className="col-4">
                <label className="form-label mb-1 small">AC</label>
                <input
                  className="form-control"
                  type="number"
                  min="1"
                  max="40"
                  value={form.ac}
                  onChange={(e) => setForm((prev) => ({ ...prev, ac: e.target.value }))}
                />
              </div>
              <div className="col-4">
                <label className="form-label mb-1 small">MS</label>
                <input
                  className="form-control"
                  type="number"
                  min="0"
                  max="120"
                  value={form.ms}
                  onChange={(e) => setForm((prev) => ({ ...prev, ms: e.target.value }))}
                />
              </div>
              <div className="col-4">
                <label className="form-label mb-1 small">HP</label>
                <input
                  className="form-control"
                  type="number"
                  min="1"
                  max="999"
                  value={form.hp}
                  onChange={(e) => setForm((prev) => ({ ...prev, hp: e.target.value }))}
                />
              </div>
            </div>
          </div>
          {canEditOwner && (
            <div className="col-12">
              <input
                className="form-control"
                placeholder="Owner ID (optional, DM only)"
                value={form.ownerId || ""}
                onChange={(e) => setForm((prev) => ({ ...prev, ownerId: e.target.value }))}
              />
              <small className="text-muted d-block mt-1">Existing owners: {owners.join(", ") || "none"}</small>
            </div>
          )}
          <div className="col-12 form-check mt-2 ms-2">
            <input
              className="form-check-input"
              type="checkbox"
              checked={Boolean(form.isActive)}
              onChange={(e) => setForm((prev) => ({ ...prev, isActive: e.target.checked }))}
              id="popup-is-active"
            />
            <label className="form-check-label" htmlFor="popup-is-active">
              Active
            </label>
          </div>
        </div>

        {error && <div className="alert alert-danger mt-3 py-2">{error}</div>}

        <div className="d-flex gap-2 mt-3">
          <button className="btn btn-primary" type="submit">
            Save sheet
          </button>
          <button className="btn btn-outline-secondary" type="button" onClick={onCancel}>
            Cancel
          </button>
        </div>
      </form>
    </div>
  );
}
