import { useEffect, useMemo, useState } from "react";
import AuthForm from "./components/AuthForm";
import CharacterForm from "./components/CharacterForm";
import CharacterList from "./components/CharacterList";
import { createCharactersEventSource, graphqlRequest, restRequest } from "./api";

const modeLabels = {
  rest: "REST",
  graphql: "GraphQL",
};

const CHAR_FIELDS = "id name className race level alignment str dex con int wis cha ac ms hp ownerId ownerName isActive createdAt updatedAt";

export default function App() {
  const [user, setUser] = useState(null);
  const [loadingAuth, setLoadingAuth] = useState(true);
  const [loadingAction, setLoadingAction] = useState(false);
  const [items, setItems] = useState([]);
  const [selected, setSelected] = useState(null);
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [error, setError] = useState("");
  const [q, setQ] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [apiMode, setApiMode] = useState("rest");

  const ownerIds = useMemo(() => Array.from(new Set(items.map((item) => item.ownerId))), [items]);

  const loadCurrentUser = async () => {
    const me = await restRequest("/api/rest/auth/me");
    setUser(me.user);
  };

  const loadCharacters = async () => {
    setError("");
    try {
      const isActive = statusFilter === "all" ? undefined : statusFilter === "active";
      if (apiMode === "rest") {
        const params = new URLSearchParams();
        if (q) params.set("q", q);
        if (typeof isActive === "boolean") params.set("isActive", String(isActive));
        const data = await restRequest(`/api/rest/characters?${params.toString()}`);
        setItems(data.items);
      } else {
        const data = await graphqlRequest(
          `query Characters($q: String, $isActive: Boolean) {
            characters(q: $q, isActive: $isActive) { ${CHAR_FIELDS} }
          }`,
          {
            q: q || null,
            isActive: typeof isActive === "boolean" ? isActive : null,
          }
        );
        setItems(data.characters);
      }
    } catch (loadError) {
      setError(loadError.message);
    }
  };

  useEffect(() => {
    (async () => {
      try {
        await loadCurrentUser();
      } catch {
        setUser(null);
      } finally {
        setLoadingAuth(false);
      }
    })();
  }, []);

  useEffect(() => {
    if (!user) return;
    loadCharacters();
  }, [user, apiMode]);

  useEffect(() => {
    if (!user) return;

    const eventSource = createCharactersEventSource();
    eventSource.onmessage = () => {
      loadCharacters();
    };
    eventSource.onerror = () => {
      eventSource.close();
    };

    return () => eventSource.close();
  }, [user, apiMode, q, statusFilter]);

  const handleRegister = async (form) => {
    return restRequest("/api/rest/auth/register", {
      method: "POST",
      body: JSON.stringify(form),
    });
  };

  const handleLogin = async (credentials) => {
    setLoadingAction(true);
    try {
      await restRequest("/api/rest/auth/login", {
        method: "POST",
        body: JSON.stringify(credentials),
      });
      await loadCurrentUser();
      await loadCharacters();
    } finally {
      setLoadingAction(false);
    }
  };

  const handleLogout = async () => {
    await restRequest("/api/rest/auth/logout", { method: "POST" });
    setUser(null);
    setItems([]);
    setSelected(null);
    setIsFormOpen(false);
  };

  const openCreatePopup = () => {
    setSelected(null);
    setIsFormOpen(true);
  };

  const openEditPopup = (item) => {
    setSelected(item);
    setIsFormOpen(true);
  };

  const closeFormPopup = () => {
    setSelected(null);
    setIsFormOpen(false);
  };

  const submitCharacter = async (payload) => {
    setLoadingAction(true);
    setError("");

    try {
      if (apiMode === "rest") {
        if (selected?.id) {
          await restRequest(`/api/rest/characters/${selected.id}`, {
            method: "PUT",
            body: JSON.stringify(payload),
          });
        } else {
          await restRequest("/api/rest/characters", {
            method: "POST",
            body: JSON.stringify(payload),
          });
        }
      } else if (selected?.id) {
        await graphqlRequest(
          `mutation UpdateCharacter($id: ID!, $name: String!, $className: String!, $race: String!, $level: Int!, $alignment: String, $str: Int!, $dex: Int!, $con: Int!, $int: Int!, $wis: Int!, $cha: Int!, $ac: Int!, $ms: Int!, $hp: Int!, $isActive: Boolean) {
            updateCharacter(id: $id, name: $name, className: $className, race: $race, level: $level, alignment: $alignment, str: $str, dex: $dex, con: $con, int: $int, wis: $wis, cha: $cha, ac: $ac, ms: $ms, hp: $hp, isActive: $isActive) {
              ${CHAR_FIELDS}
            }
          }`,
          {
            id: String(selected.id),
            ...payload,
          }
        );
      } else {
        await graphqlRequest(
          `mutation CreateCharacter($name: String!, $className: String!, $race: String!, $level: Int!, $alignment: String, $str: Int!, $dex: Int!, $con: Int!, $int: Int!, $wis: Int!, $cha: Int!, $ac: Int!, $ms: Int!, $hp: Int!, $ownerId: Int, $isActive: Boolean) {
            createCharacter(name: $name, className: $className, race: $race, level: $level, alignment: $alignment, str: $str, dex: $dex, con: $con, int: $int, wis: $wis, cha: $cha, ac: $ac, ms: $ms, hp: $hp, ownerId: $ownerId, isActive: $isActive) {
              ${CHAR_FIELDS}
            }
          }`,
          payload
        );
      }

      closeFormPopup();
      await loadCharacters();
    } catch (submitError) {
      setError(submitError.message);
    } finally {
      setLoadingAction(false);
    }
  };

  const deleteCharacter = async (id) => {
    setLoadingAction(true);
    setError("");
    try {
      if (apiMode === "rest") {
        await restRequest(`/api/rest/characters/${id}`, { method: "DELETE" });
      } else {
        await graphqlRequest(
          `mutation DeleteCharacter($id: ID!) { deleteCharacter(id: $id) }`,
          { id: String(id) }
        );
      }
      if (selected?.id === id) setSelected(null);
      await loadCharacters();
    } catch (deleteError) {
      setError(deleteError.message);
    } finally {
      setLoadingAction(false);
    }
  };

  const toggleActive = async (id, isActive) => {
    setLoadingAction(true);
    setError("");
    try {
      if (apiMode === "rest") {
        await restRequest(`/api/rest/characters/${id}/activation`, {
          method: "PATCH",
          body: JSON.stringify({ isActive }),
        });
      } else {
        await graphqlRequest(
          `mutation ToggleCharacter($id: ID!, $isActive: Boolean!) {
            toggleCharacterActive(id: $id, isActive: $isActive) { id isActive }
          }`,
          { id: String(id), isActive }
        );
      }
      await loadCharacters();
    } catch (toggleError) {
      setError(toggleError.message);
    } finally {
      setLoadingAction(false);
    }
  };

  if (loadingAuth) {
    return <div className="app-shell p-5">Loading...</div>;
  }

  if (!user) {
    return (
      <div className="app-shell auth-shell">
        <AuthForm onLogin={handleLogin} onRegister={handleRegister} isLoading={loadingAction} />
      </div>
    );
  }

  return (
    <div className="app-shell">
      <div className="container py-4">
        <header className="topbar mb-3">
          <div>
            <p className="eyebrow m-0">Resource Center</p>
            <h1 className="m-0 app-title">DnD Combat Assistant</h1>
          </div>
          <div className="d-flex gap-2 align-items-center">
            <button className="btn btn-primary" onClick={openCreatePopup}>+ Character</button>
            <button className="btn btn-outline-dark" onClick={() => setApiMode((prev) => (prev === "rest" ? "graphql" : "rest"))}>
              API: {modeLabels[apiMode]}
            </button>
            <button className="btn btn-dark" onClick={handleLogout}>Logout</button>
          </div>
        </header>

        <div className="dashboard-grid">
          <aside className="panel-stack">
            <section className="card p-3 profile-card">
              <div className="small text-uppercase fw-semibold text-muted">Session</div>
              <div className="mt-2 fw-semibold">{user.firstName} {user.lastName}</div>
              <div className="text-muted small">Role: {user.role}</div>
              <div className="text-muted small">Characters loaded: {items.length}</div>
            </section>

            <section className="card p-3">
              <div className="small text-uppercase fw-semibold text-muted mb-2">Search & Filters</div>
              <div className="d-grid gap-2">
                <input
                  className="form-control"
                  placeholder="Search by name, race, class or alignment"
                  value={q}
                  onChange={(e) => setQ(e.target.value)}
                />
                <select className="form-select" value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)}>
                  <option value="all">All statuses</option>
                  <option value="active">Only active</option>
                  <option value="inactive">Only inactive</option>
                </select>
                <button className="btn btn-primary" onClick={loadCharacters}>Apply filters</button>
              </div>
            </section>

            {loadingAction && <p className="px-1 m-0 small text-muted">Syncing character changes...</p>}
          </aside>

          <main className="card p-3 roster-shell">
            <div className="d-flex justify-content-between align-items-center mb-2">
              <div>
                <div className="small text-uppercase fw-semibold text-muted">Live Roster</div>
                <h5 className="m-0">Encounter View</h5>
              </div>
              <div className="d-flex align-items-center gap-2">
                <span className="badge rounded-pill text-bg-light">{items.length} entries</span>
                <button className="btn btn-sm btn-primary" onClick={openCreatePopup}>+ Add</button>
              </div>
            </div>

            {error && <div className="alert alert-danger py-2">{error}</div>}

            <CharacterList
              items={items}
              onEdit={openEditPopup}
              onDelete={deleteCharacter}
              onToggleActive={toggleActive}
              userRole={user.role}
              currentUserId={user.id}
            />
          </main>
        </div>

        <CharacterForm
          isOpen={isFormOpen}
          selected={selected}
          onSubmit={submitCharacter}
          onCancel={closeFormPopup}
          canEditOwner={user.role === "dm"}
          owners={ownerIds}
        />
      </div>
    </div>
  );
}
