export default function CharacterList({ items, onEdit, onDelete, onToggleActive, userRole, currentUserId }) {
  return (
    <div className="h-100">
      <div className="roster-grid">
        {items.map((item) => {
          const canManage = userRole === "dm" || item.ownerId === currentUserId;
          const canToggleActive = userRole === "dm";
          const canEdit = canManage && item.isActive;
          return (
            <article className="combat-entry" key={item.id}>
              <div className="d-flex justify-content-between align-items-start gap-2">
                <div>
                  <h6 className="m-0 fw-bold">{item.name}</h6>
                  <p className="m-0 small text-muted">{item.className} {item.race} • Lvl {item.level}</p>
                  <p className="m-0 small text-muted">{item.alignment || "No alignment"}</p>
                </div>
                <span className={`badge ${item.isActive ? "text-bg-success" : "text-bg-secondary"}`}>
                  {item.isActive ? "Active" : "Disabled"}
                </span>
              </div>

              <div className="entry-combat mt-3">
                <div className="metric"><span>AC</span><strong>{item.ac}</strong></div>
                <div className="metric"><span>MS</span><strong>{item.ms}</strong></div>
                <div className="metric hp"><span>HP</span><strong>{item.hp}</strong></div>
              </div>

              <div className="stat-grid mt-3">
                <span>STR {item.str}</span>
                <span>DEX {item.dex}</span>
                <span>CON {item.con}</span>
                <span>INT {item.int}</span>
                <span>WIS {item.wis}</span>
                <span>CHA {item.cha}</span>
              </div>

              <div className="small text-muted mt-3">Owner: #{item.ownerId} {item.ownerName}</div>

              {canManage && (
                <div className="d-flex gap-2 mt-3">
                  {canEdit && (
                    <button className="btn btn-sm btn-outline-primary" onClick={() => onEdit(item)}>Edit</button>
                  )}
                  {canToggleActive && (
                    <button className="btn btn-sm btn-outline-warning" onClick={() => onToggleActive(item.id, !item.isActive)}>
                      {item.isActive ? "Deactivate" : "Activate"}
                    </button>
                  )}
                  <button className="btn btn-sm btn-outline-danger" onClick={() => onDelete(item.id)}>Delete</button>
                </div>
              )}
            </article>
          );
        })}
      </div>

      {items.length === 0 && (
        <div className="text-center text-muted py-5">No characters found</div>
      )}
    </div>
  );
}
