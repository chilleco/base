#!/usr/bin/env bash

set -euo pipefail

project="${1:-base}"
relay_dir="infra/sentry/relay"
relay_config="${relay_dir}/config.yml"
relay_credentials="${relay_dir}/credentials.json"

is_valid_credentials() {
  local file_path="$1"
  grep -q '"public_key"' "${file_path}" && grep -q '"secret_key"' "${file_path}"
}

ensure_relay_permissions() {
  chmod 755 "${relay_dir}" 2>/dev/null || true
  [[ -e "${relay_config}" ]] && chmod 644 "${relay_config}" 2>/dev/null || true
  [[ -e "${relay_credentials}" ]] && chmod 644 "${relay_credentials}" 2>/dev/null || true
}

write_default_relay_config() {
  cat > "${relay_config}" <<'YAML'
relay:
  mode: managed
  upstream: "http://sentry-web:9000/"
  host: 0.0.0.0
  port: 3000

logging:
  level: WARN
YAML
}

mkdir -p "${relay_dir}"
ensure_relay_permissions

if [[ ! -s "${relay_config}" ]]; then
  write_default_relay_config
fi
ensure_relay_permissions

if grep -q '^[[:space:]]*processing:' "${relay_config}" && ! grep -q 'kafka_config' "${relay_config}"; then
  echo "Relay config has 'processing' enabled without 'kafka_config', resetting to default config."
  write_default_relay_config
fi

if [[ -e "${relay_credentials}" && ! -s "${relay_credentials}" ]]; then
  echo "Relay credentials are empty, regenerating: ${relay_credentials}"
  rm -f "${relay_credentials}"
fi

if [[ -s "${relay_credentials}" ]]; then
  if is_valid_credentials "${relay_credentials}"; then
    ensure_relay_permissions
    echo "Relay credentials already exist: ${relay_credentials}"
    exit 0
  fi

  echo "Relay credentials are invalid, regenerating: ${relay_credentials}"
  rm -f "${relay_credentials}"
fi

tmp_credentials="${relay_credentials}.tmp"
rm -f "${tmp_credentials}"

# Pull first to avoid implicit pull output polluting generated JSON.
docker compose -p "${project}" pull sentry-relay >/dev/null 2>&1 || true
docker compose -p "${project}" run --rm --no-deps -T sentry-relay credentials generate --stdout > "${tmp_credentials}"

if ! is_valid_credentials "${tmp_credentials}"; then
  echo "Failed to generate valid relay credentials."
  echo "--- ${tmp_credentials} ---"
  cat "${tmp_credentials}" || true
  echo "--- end ---"
  rm -f "${tmp_credentials}"
  exit 1
fi

mv "${tmp_credentials}" "${relay_credentials}"
ensure_relay_permissions
echo "Relay credentials written to ${relay_credentials}"
