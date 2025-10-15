const express = require("express");
const bodyParser = require("body-parser");
const cookieParser = require("cookie-parser");
const mongoSanitize = require("express-mongo-sanitize");
const helmet = require("helmet");
const crypto = require("crypto");
const emailRoutes = require("./routes/email-routes");
const cors = require("cors");
const app = express();

// Trust proxy (needed if behind a reverse proxy or load balancer)
app.set('trust proxy', 1);

// Body parsers
app.use(express.json({ limit: "200mb" }));
app.use(bodyParser.json({ limit: "200mb" }));
app.use(bodyParser.urlencoded({ limit: "200mb", extended: true }));
app.use(cookieParser());

// MongoDB sanitization
app.use(
  mongoSanitize({
    replaceWith: "_",
    onSanitize: ({ req, key }) => {
      console.warn(`[SECURITY] NoSQL injection attempt blocked: ${key} from IP: ${req.ip}`);
    },
  })
);

// Helmet security headers
app.use(
  helmet({
    crossOriginResourcePolicy: { policy: "same-origin" },
  })
);
app.use(helmet.noSniff());
app.use(helmet.hidePoweredBy());

// Strict Content Security Policy (CSP) with nonce
app.use((req, res, next) => {
  res.locals.cspNonce = crypto.randomBytes(16).toString("hex");
  next();
});

app.use(
  helmet.contentSecurityPolicy({
    useDefaults: false,
    directives: {
      "default-src": ["'self'"],
      "script-src": ["'self'"],
      "style-src": ["'self'", (req, res) => `'nonce-${res.locals.cspNonce}'`],
      "img-src": ["'self'", "data:"],
      "font-src": ["'self'"],
      "object-src": ["'none'"],
      "base-uri": ["'self'"],
      "form-action": ["'self'"],
      "frame-ancestors": ["'none'"],
      "upgrade-insecure-requests": [],
    },
  })
);

// SQL Injection Detection Middleware
app.use((req, res, next) => {
  const sqlInjectionPatterns = [
    /\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|UNION|DECLARE)\b/gi,
    /(--|;|\/\*|\*\/|xp_|sp_)/gi,
    /\b(OR|AND)\b\s+\d+\s*=\s*\d+/gi,
    /('.*OR.*'.*=.*'|".*OR.*".*=.*")/gi,
    /(WAITFOR|DELAY|SLEEP|BENCHMARK)/gi,
  ];

  const checkForSQLInjection = (obj, path = "") => {
    for (let key in obj) {
      const currentPath = path ? `${path}.${key}` : key;
      if (typeof obj[key] === "string") {
        const value = obj[key];
        for (let pattern of sqlInjectionPatterns) {
          if (pattern.test(value)) {
            console.error(`[SECURITY ALERT] SQL injection detected in ${currentPath}`);
            console.error(`Value: ${value}, IP: ${req.ip}, User-Agent: ${req.get("user-agent")}`);
            return true;
          }
        }
        const quoteCount = (value.match(/'/g) || []).length;
        if (quoteCount > 2) {
          console.warn(`[SECURITY] Suspicious quote count in ${currentPath}: ${quoteCount}`);
          return true;
        }
      } else if (typeof obj[key] === "object" && obj[key] !== null) {
        if (checkForSQLInjection(obj[key], currentPath)) return true;
      }
    }
    return false;
  };

  if (
    checkForSQLInjection(req.body) ||
    checkForSQLInjection(req.query) ||
    checkForSQLInjection(req.params)
  ) {
    return res.status(400).json({
      error: "Invalid input detected",
      message: "Your request contains potentially malicious content",
    });
  }

  next();
});

// Keep your simple CORS config as-is
const corsOptions = {
  origin: function (origin, callback) {
    const allowedOrigins = [
      "https://stakeplot.com",
      "https://www.stakeplot.com",
    ];

    if (process.env.NODE_ENV === "development") {
      allowedOrigins.push("http://localhost:3000");
      allowedOrigins.push("http://localhost:3001");
    }

    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      console.warn(`[SECURITY] Blocked CORS request from: ${origin}`);
      callback(new Error("Not allowed by CORS"));
    }
  },
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
  credentials: true,
  maxAge: 600,
};

app.use(cors(corsOptions));

// ✅ Handle CORS errors gracefully
app.use((err, req, res, next) => {
  if (err.message === "Not allowed by CORS") {
    return res.status(403).json({
      error: "CORS Error",
      message: "Origin not allowed",
    });
  }
  next(err);
});


// Routes
app.use("/api", emailRoutes);

// Health check
app.get("/", (req, res) => {
  res.send("server is running and healthy");
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: "Not Found",
    message: "The requested resource does not exist",
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error("[ERROR]", {
    message: err.message,
    stack: process.env.NODE_ENV === "development" ? err.stack : undefined,
    path: req.path,
    method: req.method,
    ip: req.ip,
  });

  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    error: statusCode === 500 ? "Internal Server Error" : err.message,
    ...(process.env.NODE_ENV === "development" && { stack: err.stack }),
  });
});

module.exports = app;
