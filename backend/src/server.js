const express = require("express");
const noCache = require("./middleware/noCache");
const app = express();

app.use(express.json());
app.use("/api", noCache);
app.use("/api/auth", require("./routes/auth"));
app.use("/api/todos", require("./routes/todo"));
app.use("/api/profile", require("./routes/profile"));

app.listen(3000, () => console.log("Server running"));