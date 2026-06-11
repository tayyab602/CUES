const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");

const app = express();

app.use(express.json());
app.use(cors());
app.use(helmet());
app.use(morgan("dev"));

// ROUTES
app.use("/api/items", require("./routes/itemRoutes"));
app.use("/api/lost", require("./routes/lostRoutes"));
app.use("/api/chat", require("./routes/chatRoutes"));
app.use("/api/claim", require("./routes/claimRoutes"));
app.use("/api/admin", require("./routes/adminRoutes"));

module.exports = app;