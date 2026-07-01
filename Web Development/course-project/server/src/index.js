const app = require("./app");
const { port } = require("./config/env");
require("./config/db");

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
