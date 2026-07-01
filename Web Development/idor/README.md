# IDOR discipline demo

Small educational Express app with a local in-memory MongoDB that compares two versions of discipline enrollment:

- Vulnerable version: the open discipline can be enrolled normally, and the closed discipline can still be enrolled by calling its direct URL with `disciplineId`.
- Protected version: the open discipline can be enrolled normally, but the closed discipline is blocked even if someone calls the direct URL manually.

## Run

1. Copy `.env.example` to `.env`
2. Install dependencies:

```bash
npm install
```

3. Start the server:

```bash
npm start
```

4. Open `http://localhost:4000`

All data is stored only in the local in-memory database and is reset after a restart.

## Demo flow

1. Open the page and note the two disciplines: one open and one closed.
2. In the vulnerable panel, enroll into the open discipline through the normal button.
3. In the same vulnerable panel, use the direct URL action on the closed discipline.
4. The enrollment succeeds even though the interface says that discipline should not be available.
5. In the protected panel, try the same direct URL action for the closed discipline.
6. The server returns `403` because the protected version validates the business rule.