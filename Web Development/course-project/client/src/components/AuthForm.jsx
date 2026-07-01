import { useState } from "react";

const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export default function AuthForm({ onLogin, onRegister, isLoading }) {
  const [mode, setMode] = useState("login");
  const [form, setForm] = useState({
    firstName: "",
    lastName: "",
    email: "",
    password: "",
  });
  const [error, setError] = useState("");
  const [verificationHint, setVerificationHint] = useState("");

  const validate = () => {
    if (!form.email || !form.password) {
      return "Email and password are required";
    }
    if (!emailRegex.test(form.email)) {
      return "Email format is invalid";
    }
    if (mode === "register" && (!form.firstName || !form.lastName)) {
      return "First and last name are required";
    }
    return "";
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setError("");
    setVerificationHint("");

    const validationError = validate();
    if (validationError) {
      setError(validationError);
      return;
    }

    try {
      if (mode === "login") {
        await onLogin({ email: form.email, password: form.password });
      } else {
        const result = await onRegister(form);
        setVerificationHint(`Registration successful. Open verification link: ${result.verifyLink}`);
        setMode("login");
      }
    } catch (submitError) {
      setError(submitError.message);
    }
  };

  return (
    <div className="auth-card shadow-lg p-4 p-md-5">
      <h1 className="display-6 fw-bold mb-3">Resource Center</h1>
      <p className="text-muted mb-4">DnD character assistant for players and dungeon masters</p>

      <div className="btn-group mb-3" role="group">
        <button
          type="button"
          className={`btn ${mode === "login" ? "btn-primary" : "btn-outline-primary"}`}
          onClick={() => setMode("login")}
        >
          Login
        </button>
        <button
          type="button"
          className={`btn ${mode === "register" ? "btn-primary" : "btn-outline-primary"}`}
          onClick={() => setMode("register")}
        >
          Register
        </button>
      </div>

      <form onSubmit={handleSubmit} className="d-grid gap-3">
        {mode === "register" && (
          <>
            <input
              className="form-control"
              placeholder="First name"
              value={form.firstName}
              onChange={(e) => setForm((prev) => ({ ...prev, firstName: e.target.value }))}
            />
            <input
              className="form-control"
              placeholder="Last name"
              value={form.lastName}
              onChange={(e) => setForm((prev) => ({ ...prev, lastName: e.target.value }))}
            />
          </>
        )}
        <input
          className="form-control"
          placeholder="Email"
          value={form.email}
          onChange={(e) => setForm((prev) => ({ ...prev, email: e.target.value }))}
        />
        <input
          className="form-control"
          placeholder="Password"
          type="password"
          value={form.password}
          onChange={(e) => setForm((prev) => ({ ...prev, password: e.target.value }))}
        />
        <button className="btn btn-dark" disabled={isLoading}>
          {isLoading ? "Please wait..." : mode === "login" ? "Login" : "Create account"}
        </button>
      </form>

      {error && <div className="alert alert-danger mt-3 py-2">{error}</div>}
      {verificationHint && <div className="alert alert-info mt-3 py-2">{verificationHint}</div>}
    </div>
  );
}
