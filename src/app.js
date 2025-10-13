const express = require("express");
const bodyParser = require("body-parser");
const cookieParser = require("cookie-parser");
const mongoSanitize = require("express-mongo-sanitize");
const helmet = require('helmet');
const cors = require("cors");
const app = express();

app.set('trust proxy', 1);
app.use(express.json());
app.use(helmet());
// app.use(rateLimit({ windowMs: 15 * 60 * 1000, max: 100 }));
app.use(cookieParser());
app.use(bodyParser.json({ limit: "200mb" }));
app.use(bodyParser.urlencoded({ limit: "200mb", extended: true }));
app.use(mongoSanitize());

app.use(cors({
  origin: "*",
  methods: "GET,POST,PUT,DELETE",
  allowedHeaders: "*",
}));

app.get("/", (req, res) => {
  res.send("server is running and healthy");
});


module.exports = app;
