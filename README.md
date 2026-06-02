# email-service

Backend microservice for Stakeplot's email authentication and scraped-data storage. Node.js (24) + TypeScript + Express, listening on **port 5001**. It connects to MongoDB (two databases), Redis, fetches secrets from AWS Secrets Manager at boot, ships logs to CloudWatch, runs Bull queues and cron jobs, and uses a Python (spaCy) process for email scraping.

This document covers **how `email-service` is built, deployed, and rolled back** across the `dev` → `qa` → `prod` environments.

---

## Table of contents

- [Architecture at a glance](#architecture-at-a-glance)
- [Branching model](#branching-model)
- [Environments & infrastructure](#environments--infrastructure)
- [How deployment works](#how-deployment-works)
  - [QA / staging deploy](#qa--staging-deploy)
  - [Production deploy](#production-deploy)
- [DevOps tooling on the instances](#devops-tooling-on-the-instances)
  - [`docker-control.base.sh`](#docker-controlbasesh)
  - [`fetch-secrets.sh`](#fetch-secretssh)
- [Deploying manually](#deploying-manually)
- [Rollback](#rollback)
- [Local development](#local-development)
- [Reference: names & IDs](#reference-names--ids)

---

## Architecture at a glance

```
                 git push            GitHub Actions                EC2 instance
 developer  ───────────────►  qa / prod branch  ──────►  build / retag image  ──►  ECR
                                                                                     │
                                                                     SSH (appleboy/ssh-action)
                                                                                     ▼
                                                          /home/ubuntu/devops-tools/scripts
                                                          ./docker-control.base.sh <env> up email-service
                                                                                     │
                                                                                     ▼
                                                            docker compose (base + env overlay)
                                                        nginx ─► email-service:5001 (+ other services)
                                                        volumes: /app/output  /app/logs
```

- **Container image** is stored in **Amazon ECR**: `058264382454.dkr.ecr.ap-south-1.amazonaws.com/email-service` (region `ap-south-1`).
- Image tags map to environments:
  - `:staging` → QA
  - `:prod` → Production
- All services (`mobile-backend`, `email-service`, `bank-service`, `prediction-service`, `redis`, `nginx`) run on a single EC2 host per environment, orchestrated by Docker Compose from the **`devops-tools`** repo at `/home/ubuntu/devops-tools`.

---

## Branching model

Three long-lived branches mirror the three environments. The code is nearly identical across them; what differs is maturity.

| Branch | Purpose | Environment | Image tag |
| ------ | ------- | ----------- | --------- |
| `dev`  | Integration branch. Staging code queued to move to QA. | none (no auto-deploy) | — |
| `qa`   | Staging code under test. | QA / staging | `:staging` |
| `prod` | Live production code. | Production | `:prod` |

**Promotion flow** (code is never written or pushed directly to `prod`):

```
feature/working branch  ──►  dev  ──►  qa  ──►  prod
   (cut from dev)          merge     merge     merge
```

1. Cut a **working / feature branch** off `dev`.
2. Write your code there and push the feature branch to remote.
3. When the work is complete, **merge into `dev`**.
4. To test on staging, **merge `dev` → `qa`** — this triggers the QA build & deploy.
5. To go live, **merge `qa` → `prod`** — this triggers the production deploy.

> The image is **built once** when code lands on `qa`. Promoting to `prod` does **not** rebuild — it re-tags the exact image that was validated on staging, so what you test is bit-for-bit what goes live.

---

## Environments & infrastructure

| | QA / staging | Production |
| --- | --- | --- |
| Domain | `staging.stakeplot.in` | `stakeplot.in` |
| Branch | `qa` | `prod` |
| Image tag | `:staging` | `:prod` |
| EC2 host secret | `QA_EC2_HOST` | `EC2_PROD_HOST` |
| Compose overlay | `docker-compose.qa.yml` | `docker-compose.prod.yml` |
| Nginx config | `nginx/conf.d/qa.conf` | `nginx/conf.d/prod.conf` |
| Control script | `docker-control.base.sh qa` | `docker-control.base.sh prod` |

Common to both:
- AWS region `ap-south-1`, ECR registry `058264382454.dkr.ecr.ap-south-1.amazonaws.com`.
- SSH user `ubuntu`, devops repo at `/home/ubuntu/devops-tools`.
- Container logs shipped to CloudWatch (`awslogs` driver), log group `/mobileqa/container-email-service`.
- Named volumes `email-service-output` (`/app/output`) and `email-service-logs` (`/app/logs`) persist scraped output and log files across container restarts.
- `nginx` terminates TLS (Let's Encrypt) and reverse-proxies to the internal service network. `email-service` is reached internally on `email-service:5001`.

---

## How deployment works

Deployment is driven by **GitHub Actions** in [`.github/workflows/`](.github/workflows/). A push (merge) to `qa` or `prod` is the only trigger — there is no workflow on `dev`.

### QA / staging deploy

Workflow: [`.github/workflows/qa.yml`](.github/workflows/qa.yml) — runs on **push to `qa`**.

Steps:
1. **Checkout** the repo.
2. **Configure AWS credentials** (`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`), region `ap-south-1`.
3. **Login to ECR** (in the CI runner).
4. **Build, tag & push** the Docker image:
   ```bash
   docker build --platform linux/amd64 -t email-service:staging .
   docker tag  email-service:staging  $ECR_REGISTRY/email-service:staging
   docker push $ECR_REGISTRY/email-service:staging
   ```
5. **Deploy on EC2** over SSH (`QA_EC2_HOST`):
   ```bash
   cd /home/ubuntu/devops-tools/scripts
   # ECR login is performed on the host before pulling
   aws ecr get-login-password --region ap-south-1 \
     | docker login --username AWS --password-stdin \
         058264382454.dkr.ecr.ap-south-1.amazonaws.com
   ./docker-control.base.sh qa down email-service
   docker rm -f email-service || true
   docker pull 058264382454.dkr.ecr.ap-south-1.amazonaws.com/email-service:staging
   ./docker-control.base.sh qa up email-service
   ```

The build happens in the GitHub Actions runner (cross-compiled to `linux/amd64`). Note that `email-service` also runs an explicit ECR login on the host before pulling — this is because the image is large (Node 24 + Python + spaCy) and the host's credentials may need a fresh token.

### Production deploy

Workflow: [`.github/workflows/prod.yml`](.github/workflows/prod.yml) — runs on **push to `prod`**.

There is **no rebuild**. The `:staging` image that already passed QA is **re-tagged as `:prod`** directly in ECR:

1. **Configure AWS credentials**, region `ap-south-1`.
2. **Retag in ECR** — pull the `staging` manifest and put it back under the `prod` tag:
   ```bash
   MANIFEST=$(aws ecr batch-get-image \
     --repository-name email-service \
     --image-ids imageTag=staging \
     --query 'images[0].imageManifest' --output text)

   aws ecr put-image \
     --repository-name email-service \
     --image-tag prod \
     --image-manifest "$MANIFEST"
   ```
3. **Deploy on EC2** over SSH (`EC2_PROD_HOST`):
   ```bash
   cd /home/ubuntu/devops-tools/scripts
   ./docker-control.base.sh prod down email-service
   docker rm -f email-service || true
   docker pull 058264382454.dkr.ecr.ap-south-1.amazonaws.com/email-service:prod
   ./docker-control.base.sh prod up email-service
   ```

---

## DevOps tooling on the instances

The [`devops-tools`](../devops-tools/) repo is checked out at `/home/ubuntu/devops-tools` on every host. Layout relevant to `email-service`:

```
devops-tools/
├── docker-compose.base.yml      # shared service definitions (image, expose 5001, CloudWatch logging)
├── docker-compose.qa.yml        # QA overlay  — :staging image, env file, output+logs volumes
├── docker-compose.prod.yml      # PROD overlay — :prod image, env file, published port 5001
├── env-config/
│   ├── qa/
│   │   ├── .env.qa.email-service.base    # non-secret config committed to repo
│   │   └── .env.qa.email-service         # generated by fetch-secrets.sh (gitignored)
│   └── prod/
│       ├── .env.prod.email-service.base
│       └── .env.prod.email-service
└── scripts/
    ├── docker-control.base.sh   # the real engine; takes <env> as first arg
    ├── docker-control.qa.sh     # thin wrapper → base.sh qa
    ├── docker-control.prod.sh   # thin wrapper → base.sh prod
    ├── fetch-secrets.sh         # pull secrets from AWS Secrets Manager → env files
    └── rollback.sh              # ECR image rollback
```

Compose files are layered: the env-specific overlay is merged **on top of** `docker-compose.base.yml`. `email-service` is defined in the base file (image, `expose: 5001`, CloudWatch logging) and the overlays pin the image tag, attach the env file, and declare the named volumes for output and logs.

### `docker-control.base.sh`

Unified entrypoint for managing containers. The `qa` / `prod` / `local` scripts are one-line wrappers.

```bash
./docker-control.base.sh <env> {up|down|restart|logs|pull|delete-container|delete-image} [service|all]
```

- `<env>`: `local` | `qa` | `prod`
- `service`: `email-service`, `mobile-backend`, `bank-service`, `prediction-service`, `redis`, `nginx`, or `all` (default)

Examples:
```bash
./docker-control.base.sh qa up email-service          # start/refresh email-service on QA
./docker-control.base.sh prod restart email-service   # restart on prod
./docker-control.base.sh qa logs email-service        # tail logs
./docker-control.base.sh prod down email-service      # stop the container
```

### `fetch-secrets.sh`

Generates the runtime env files by merging the committed `.base` config with secrets pulled from **AWS Secrets Manager**. Run it **before** bringing services up.

```bash
./fetch-secrets.sh <environment> [service|all]   # environment: qa | prod
```

- Secret path: `stakeplot/<staging|prod>/<service>` (e.g. `stakeplot/staging/email-service`).
- Reads `env-config/<env>/.env.<env>.email-service.base`, appends the decoded secret keys, and writes `env-config/<env>/.env.<env>.email-service` with `chmod 600`.
- Requires the EC2 IAM role to have `secretsmanager:GetSecretValue`, plus `aws` CLI and `python3`.

```bash
./fetch-secrets.sh qa email-service    # regenerate the QA env file for email-service
./fetch-secrets.sh prod all            # regenerate all prod env files
```

> Note: `email-service` also calls `loadSecrets()` at application startup (see [`src/index.ts`](src/index.ts)), so secrets are injected into `process.env` before cron jobs and Bull queues initialise.

---

## Deploying manually

The CI handles deploys automatically, but you can reproduce the steps by hand if you ever need to.

**Build & push from your local working directory** (image is built locally, then pushed to ECR):
```bash
# from email-service/
aws ecr get-login-password --region ap-south-1 \
  | docker login --username AWS --password-stdin 058264382454.dkr.ecr.ap-south-1.amazonaws.com

docker build --platform linux/amd64 -t email-service:staging .
docker tag  email-service:staging  058264382454.dkr.ecr.ap-south-1.amazonaws.com/email-service:staging
docker push 058264382454.dkr.ecr.ap-south-1.amazonaws.com/email-service:staging
```

> The image includes Node 24, Python 3, pip, and spaCy (`en_core_web_sm`), so the build takes longer than a typical Node service. Build times of several minutes are normal.

**Pull & restart on the host** (SSH into the EC2 instance):
```bash
cd /home/ubuntu/devops-tools/scripts
./fetch-secrets.sh qa email-service        # if env/secrets changed
# ECR login on the host
aws ecr get-login-password --region ap-south-1 \
  | docker login --username AWS --password-stdin \
      058264382454.dkr.ecr.ap-south-1.amazonaws.com
./docker-control.base.sh qa down email-service
docker rm -f email-service || true
docker pull 058264382454.dkr.ecr.ap-south-1.amazonaws.com/email-service:staging
./docker-control.base.sh qa up email-service
```

For production, retag `:staging` → `:prod` in ECR (don't rebuild) and substitute `prod` for `qa` in the commands above, mirroring [`prod.yml`](.github/workflows/prod.yml).

---

## Rollback

Use [`devops-tools/scripts/rollback.sh`](../devops-tools/scripts/rollback.sh) to revert `email-service` to a previous image. It re-points the environment's ECR tag (`staging` for qa, `prod` for prod) at an older digest, then pulls and restarts the container.

```bash
./rollback.sh <env> <service> <action>
```

- `<env>`: `qa` | `prod`
- `<action>`:
  - `list` — show all images in ECR for the service, newest first (tags + digests + push time)
  - `previous` — roll back to the image immediately before the currently-tagged one
  - `staging` — re-point to the current `staging` image
  - `sha256:<digest>` — roll back to a specific image digest

Typical sequence:
```bash
cd /home/ubuntu/devops-tools/scripts

./rollback.sh prod email-service list                  # find the digest you want
./rollback.sh prod email-service previous              # one step back, or…
./rollback.sh prod email-service sha256:abc123...      # pin to a specific image
```

What the script does internally:
1. Logs in to ECR.
2. Resolves the target image **digest** from the action.
3. Re-tags that digest as `staging`/`prod` in ECR (`aws ecr put-image`).
4. `docker rm -f <service>`, `docker pull <image>:<tag>`, then `docker-control.base.sh <env> up <service>`.

> Named volumes (`email-service-output`, `email-service-logs`) are **not** affected by a rollback — their data is preserved across container replacements.

---

## Local development

Run the service directly (hot reload via `ts-node-dev`):
```bash
npm install
npm run dev        # watches src/, port 5001, loads local .env
```

Other scripts (see [`package.json`](package.json)):
```bash
npm run lint       # eslint
npm test           # jest
```

There is no separate `build` step — the service runs TypeScript directly via `ts-node-dev` in all environments including the container (the Dockerfile `CMD` is `npm run dev`).

Or run the whole stack with Docker Compose via the local overlay:
```bash
cd ../devops-tools/scripts
./docker-control.local.sh up email-service
```

---

## Reference: names & IDs

| Item | Value |
| ---- | ----- |
| Service port | `5001` |
| AWS region | `ap-south-1` |
| ECR registry | `058264382454.dkr.ecr.ap-south-1.amazonaws.com` |
| ECR repository | `email-service` |
| QA image tag | `staging` |
| Prod image tag | `prod` |
| Secrets Manager path | `stakeplot/<staging\|prod>/email-service` |
| CloudWatch log group | `/mobileqa/container-email-service` |
| Persistent volumes | `email-service-output` (`/app/output`), `email-service-logs` (`/app/logs`) |
| Devops repo on host | `/home/ubuntu/devops-tools` |
| SSH user | `ubuntu` |

**GitHub Actions secrets used:** `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `QA_EC2_HOST` (QA), `EC2_PROD_HOST` (prod), `EC2_KEY` (SSH private key).
