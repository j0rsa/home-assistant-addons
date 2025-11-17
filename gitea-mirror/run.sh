#!/usr/bin/env bash
set -euo pipefail
umask 002

CONFIG_PATH="/data/options.json"
DATA_DIR="/data/gitea-mirror"
APP_DATA_LINK="/app/data"
APP_ENTRYPOINT="/app/docker-entrypoint.sh"
RUN_USER="gitea-mirror"
RUN_GROUP="nodejs"

log() {
  local level="$1"; shift
  printf '[%s] [%s] %s\n' "$(date --iso-8601=seconds)" "${level}" "$*"
}

wait_for_config() {
  local retries=0
  while [ ! -f "${CONFIG_PATH}" ]; do
    if [ "${retries}" -ge 30 ]; then
      log "ERROR" "Could not find ${CONFIG_PATH} after waiting."
      exit 1
    fi
    log "INFO" "Waiting for Home Assistant to write ${CONFIG_PATH} ..."
    sleep 1
    retries=$((retries + 1))
  done
}

jq_string() {
  local key="$1" default_value="$2"
  jq -r --arg key "${key}" --arg default "${default_value}" '
    if has($key) and .[$key] != null and (.[$key] | tostring | length > 0) then
      .[$key]
    else
      $default
    end
  ' "${CONFIG_PATH}"
}

jq_bool() {
  local key="$1" default_value="$2"
  jq -r --arg key "${key}" --argjson default "${default_value}" '
    if has($key) and .[$key] != null then
      .[$key]
    else
      $default
    end
  ' "${CONFIG_PATH}"
}

populate_trusted_origins() {
  mapfile -t TRUSTED_ORIGINS < <(jq -r '(.trusted_origins // [])[]' "${CONFIG_PATH}") || true
  if [ ${#TRUSTED_ORIGINS[@]} -eq 0 ]; then
    TRUSTED_ORIGINS=("${BETTER_AUTH_URL}")
  fi
  local old_ifs="${IFS}"
  IFS=',' 
  local joined="${TRUSTED_ORIGINS[*]}"
  IFS="${old_ifs}"
  export BETTER_AUTH_TRUSTED_ORIGINS="${joined}"
}

set_optional_env() {
  local env_name="$1" key="$2" value
  value="$(jq_string "${key}" "")"
  if [ -n "${value}" ]; then
    export "${env_name}"="${value}"
  fi
}

set_bool_env() {
  local env_name="$1" key="$2" default="$3"
  local value
  value="$(jq_bool "${key}" "${default}")"
  export "${env_name}"="${value}"
}

wait_for_config

mkdir -p "${DATA_DIR}"
chown -R "${RUN_USER}:${RUN_GROUP}" "${DATA_DIR}"
if [ -e "${APP_DATA_LINK}" ] && [ ! -L "${APP_DATA_LINK}" ]; then
  rm -rf "${APP_DATA_LINK}"
fi
if [ ! -L "${APP_DATA_LINK}" ]; then
  ln -s "${DATA_DIR}" "${APP_DATA_LINK}"
fi

export HOST="0.0.0.0"
export PORT="4321"

BETTER_AUTH_URL="$(jq_string "better_auth_url" "http://127.0.0.1:4321")"
export BETTER_AUTH_URL
PUBLIC_BETTER_AUTH_URL="$(jq_string "public_better_auth_url" "")"
if [ -n "${PUBLIC_BETTER_AUTH_URL}" ]; then
  export PUBLIC_BETTER_AUTH_URL
fi

populate_trusted_origins

set_optional_env "GITHUB_USERNAME" "github_username"
set_optional_env "GITHUB_TOKEN" "github_token"
set_optional_env "GITHUB_APP_ID" "github_app_id"
set_optional_env "GITHUB_APP_INSTALLATION_ID" "github_app_installation_id"
set_optional_env "GITHUB_APP_PRIVATE_KEY" "github_app_private_key"
set_optional_env "GITEA_URL" "gitea_url"
set_optional_env "GITEA_TOKEN" "gitea_token"
set_optional_env "GITEA_USERNAME" "gitea_username"
set_optional_env "GITEA_ORGANIZATION" "gitea_organization"

set_bool_env "PRIVATE_REPOSITORIES" "mirror_private" true
set_bool_env "PUBLIC_REPOSITORIES" "mirror_public" true
set_bool_env "INCLUDE_ARCHIVED" "include_archived" false
set_bool_env "SKIP_FORKS" "skip_forks" false
set_bool_env "MIRROR_STARRED" "mirror_starred" false
set_bool_env "MIRROR_ORGANIZATIONS" "mirror_orgs" false
set_bool_env "PRESERVE_ORG_STRUCTURE" "preserve_org_structure" false
set_bool_env "ONLY_MIRROR_ORGS" "only_mirror_orgs" false
set_bool_env "SCHEDULE_ENABLED" "schedule_enabled" true
set_bool_env "GITEA_SKIP_TLS_VERIFY" "gitea_skip_tls_verify" false

GITHUB_TYPE="$(jq_string "github_account_type" "personal")"
export GITHUB_TYPE

MIRROR_INTERVAL="$(jq_string "mirror_interval" "8h")"
if [ -n "${MIRROR_INTERVAL}" ]; then
  export GITEA_MIRROR_INTERVAL="${MIRROR_INTERVAL}"
fi

if [ ! -x "${APP_ENTRYPOINT}" ]; then
  log "ERROR" "Upstream entrypoint ${APP_ENTRYPOINT} not found or not executable."
  exit 1
fi

log "INFO" "Starting Gitea Mirror with scheduler interval ${MIRROR_INTERVAL} and trusted origins ${BETTER_AUTH_TRUSTED_ORIGINS}" || true

exec su-exec "${RUN_USER}:${RUN_GROUP}" "${APP_ENTRYPOINT}"
