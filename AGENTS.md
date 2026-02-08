# Repository Guidelines

## Project Structure & Module Organization
This repository manages the infrastructure stack for the `chill` ecosystem.

- `compose.yml`: main Docker Compose definition for MinIO, MongoDB, Prometheus, Loki, Alloy, and Grafana.
- `infra/`: service-level configuration (`nginx/`, `mongo/`, `prometheus/`, `loki/`, `alloy/`, `grafana/`).
- `scripts/`: helper scripts (`scripts/main.py`, `scripts/lib/s3.py`).
- `.github/workflows/deploy.yml`: deploy pipeline for `main`.
- `.env.example`: template for local environment variables.

## Build, Test, and Development Commands
- `make up`: build and start all services in detached mode (`docker compose -p base up --build -d`).
- `make down`: stop running stack containers.
- `make status`: show container status and exposed ports.
- `make mongo`: open `mongosh` inside the running MongoDB container.
- `make set`: render Nginx config with `envsubst`, restart Nginx, and run Certbot (requires `sudo` and host setup).
- `make certs`: re-run certificate issuance flow.

## Coding Style & Naming Conventions
- Python: PEP 8 style, 4-space indentation, `snake_case` for functions/variables, short module-level docstrings.
- YAML/Compose: 2-space indentation, lowercase service names (`base-mongo`, `base-grafana`).
- Environment variables: uppercase with clear prefixes (`MONGO_*`, `GRAFANA_*`, ...) with entity suffix (`USER` for admin/user login, `PASS` for admin/user password/key, `ID` for account/user/application ID, `TOKEN` for account/user/application secret token, `PORT` for container port exporting, ...).
- Keep config files service-scoped under `infra/<service>/` and avoid cross-service coupling in a single file.

## Testing Guidelines
There is no formal automated test suite yet. Validate changes with infrastructure smoke checks:

1. `docker compose -p base config` (sanity-check Compose syntax).
2. `make up` then `make status` (container health and ports).
3. Verify affected service endpoints/UI paths (for example, `/grafana/` or `/prometheus/`).

## Commit & Pull Request Guidelines
- Follow existing history style: short, imperative commit subjects (for example, `Fix mongodb on`, `Update routes`).
- Keep commits scoped to one concern (service config, deployment logic, or scripts).
- PRs should include:
  - What changed and why.
  - Affected services and required env changes.
  - Manual verification steps and results.
  - Screenshots for dashboard/UI updates (Grafana/Nginx routing changes).

## Security & Configuration Tips
- Never commit real secrets; copy `.env.example` to `.env` and keep credentials local.
- Ensure `DATA_PATH` directories exist and are writable before `make up`.
- Treat `make set` and TLS changes as production-impacting operations; review host/domain variables first.
