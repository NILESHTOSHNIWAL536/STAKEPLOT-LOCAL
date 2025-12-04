# Copilot / AI agent instructions — stakeplot/bank-service

Quick orientation
- This is a Node.js backend for the Stakeplot mobile app. The repo contains a TypeScript-first codebase under `src2/` and a legacy JavaScript copy under `src/`.
- Primary development surface: `src2/` (TypeScript). Prefer edits in `src2`. `src/` is legacy; only touch it when necessary or when migrating features.

How to run (developer flows)
- Dev (fast edit/run): npm run dev — runs `ts-node src2/index.ts`. Use this for iterative development and debugging.
- Build for production: npm run build — runs `tsc` and emits `dist/`.
- Start production image: npm run build && npm run start (start runs `node dist/index.js`). Ensure `dist/` exists before `start`.
- Lint: npm run lint. Tests: npm test (Jest). If tests fail, confirm TypeScript build or ts-jest config.

Important patterns & architecture (what to look at)
- Entrypoints: `src2/index.ts` and `src/index.js` — both load dotenv with path `./config/.env.${NODE_ENV}`. dotenv path is resolved from process.cwd(), so check `config/` at repo root and `src2/config/` when troubleshooting env loading.
- Express app: `src2/app.ts` — sets middlewares (`corsMiddleware`, `securityMiddleware`, `metricsMiddleware`), mounts routes under `/api`, and defines health check at `/`.
- Routes: `src2/routes/*` (e.g., `transaction-routes`, `notifications`). Controllers live under `src2/controllers/`. Models are in `src2/models/`.
- Config: `src2/config/*` (e.g., `server-config.ts`, `redis-config.ts`, `categoryWeights.ts`). `ServerConfig` exports PORT, MONGO_URI, JWT_SECRET.
- Persistence & infra: connects to MongoDB (mongoose), Redis, uses Bull/BullMQ for queues, and conditionally configures CloudWatch logs in production (`winston-cloudwatch`). See `src2/utils/common/logger.ts` and `src2/config/redis-config.ts`.

Conventions agents should follow
- Prefer `import`/`export` (ES modules) and TypeScript types for new code inside `src2/`.
- Use the project's logger (`src2/utils/common/logger.ts`) instead of console.log in new features or fixes. Logging writes to `logs/debug.log` and adds CloudWatch transport in production.
- Follow the centralized error handling: use the route handlers and throw/next errors so `globalErrorHandler` handles formatting.
- Keep route paths and controllers consistent with existing patterns (routes register under `router.use('/transaction', ...)`, etc.).

Environment and secrets
- dotenv is invoked with `./config/.env.${NODE_ENV}`. Check both repo root `config/` and `src2/config/` for env expectations. Typical keys: PORT, MONGO_URI, JWT_SECRET, AWS_REGION, etc.
- AWS SDK v3 clients are used (see package.json). Be careful when changing AWS calls — ensure credentials are available in environment or IAM roles.

Tests and CI notes
- Jest is present in `devDependencies`. If adding TypeScript tests, either ensure ts-jest is configured or run `npm run build` before `npm test`.
- There's no repository workflow files detected; if requested, create `.github/workflows/*` to run build/test/lint.

Where to look for common tasks/examples
- Health check and route mounting: `src2/app.ts`.
- Server start and infra connection: `src2/index.ts` and `src/index.js` (legacy).
- Logger: `src2/utils/common/logger.ts` (shows production CloudWatch usage).
- Routes: `src2/routes/index.ts` and per-feature routes like `transaction-routes`.
- Cron or background jobs: legacy `src/utils/cron-jobs.js` and `src/config/categoryWatcher.js` — search for `cron-jobs` and `categoryWatcher` when working on scheduled tasks.

Small actionable examples for an agent
- Fix an API bug: run `npm run dev`, reproduce, add a unit/integration test (jest) in `src2/__tests__` or next to the module, implement fix in `src2/`, run `npm run build`, then `npm test`.
- Add a new route: create route under `src2/routes/`, add controller under `src2/controllers/`, register in `src2/routes/index.ts`, and add a small integration test.

Notes and gotchas
- Mixed codebase: be explicit which folder you edit (`src2/` vs `src/`). New work should target `src2/` unless there's a migration task.
- dotenv path and process.cwd() may cause env files to be read from unexpected locations — if env values are missing, check both `config/` (repo root) and `src2/config/`.
- When editing logging or CloudWatch, only enable cloudwatch transport behind NODE_ENV=production as in `logger.ts`.

If anything here is unclear or you want me to add CI workflow templates, tests, or update conventions for a specific directory, tell me which area to expand.
