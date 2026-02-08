#!/usr/bin/env bash

set -euo pipefail

project="${1:-base}"
relay_dir="infra/sentry/relay"
relay_config="${relay_dir}/config.yml"
relay_credentials="${relay_dir}/credentials.json"

mkdir -p "${relay_dir}"

if [[ ! -s "${relay_config}" ]]; then
  cat > "${relay_config}" <<'YAML'
relay:
  mode: managed
  upstream: "http://sentry-web:9000/"
  host: 0.0.0.0
  port: 3000

logging:
  level: WARN
YAML
fi

if [[ -s "${relay_credentials}" ]]; then
  echo "Relay credentials already exist: ${relay_credentials}"
  exit 0
fi

tmp_credentials="${relay_credentials}.tmp"
rm -f "${tmp_credentials}"

# Pull first to avoid implicit pull output polluting generated JSON.
docker compose -p "${project}" pull sentry-relay >/dev/null 2>&1 || true
docker compose -p "${project}" run --rm --no-deps -T sentry-relay credentials generate --stdout > "${tmp_credentials}"

if ! grep -q '"public_key"' "${tmp_credentials}" || ! grep -q '"secret_key"' "${tmp_credentials}"; then
  echo "Failed to generate valid relay credentials."
  echo "--- ${tmp_credentials} ---"
  cat "${tmp_credentials}" || true
  echo "--- end ---"
  rm -f "${tmp_credentials}"
  exit 1
fi

mv "${tmp_credentials}" "${relay_credentials}"
chmod 600 "${relay_credentials}" || true
echo "Relay credentials written to ${relay_credentials}"
