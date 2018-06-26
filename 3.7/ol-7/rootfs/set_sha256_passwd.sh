#!/usr/bin/env bash

set -e

if [[ "$1" == "--sleep" ]]; then
  sleep $2
fi

if [[ -r /opt/bitnami/base/helpers ]]; then
  . /opt/bitnami/base/helpers
else
  info()  { echo >&2 "INFO: $@"; }
  warn()  { echo >&2 "WARNING: $@"; }
  error() { echo >&2 "ERROR: $@"; }
fi

# details on rabbitMQ password hashing
## https://www.rabbitmq.com/passwords.html#computing-password-hash
#
# Example RABBITMQ_PASSWORD_SHA256
## plain  : bitnami256
## SHA256 : dBfy7O8HZa1/E/KOHLB5Weu4e38bcDcUPxiFW1dLLqbx3Pag

if [[ "x${RABBITMQ_PASSWORD_SHA256:-x}x" == "xxx" ]]; then
  warn 'RABBITMQ_PASSWORD_SHA256 environment variable is not set, nothing to do here..'
  exit 0
else
  warn 'RABBITMQ_PASSWORD_SHA256 environment variable detected'
  warn "  going to use it to set password for \"${RABBITMQ_USERNAME}\""
fi

attempt_ttl=30
curl_auth="${RABBITMQ_USERNAME}:${RABBITMQ_PASSWORD}"
api_url="http://localhost:${RABBITMQ_MANAGER_PORT_NUMBER}/api"

time_start=$(date +%s)

passwd_payload=$(cat <<EOM
{
  "password_hash":"${RABBITMQ_PASSWORD_SHA256}",
  "tags":"administrator"
}
EOM
)

curl_cmd="curl -sS -o /dev/null -u ${curl_auth} -w %{http_code}"

whoami() {
  $curl_cmd ${api_url}/whoami | grep -q 200
}

set_passwd() {
  $curl_cmd -X PUT -d "${passwd_payload}" ${api_url}/users/${RABBITMQ_USERNAME} | grep -q 204
}

while ! whoami; do
  if [[ ${attempt_ttl:-0} -lt 1 ]]; then
    seconds_trying=$(( $(date +%s)-$time_start ))
    error "failed to authenticate with default credentials after $seconds_trying seconds trying, exiting.."
    exit 1
  fi
  let attempt_ttl--
  warn "failed to authenticate using default user/pass, ${attempt_ttl} attempt(s) remaining.." 
  sleep 1
done

if set_passwd; then
  info "\"${RABBITMQ_USERNAME}\" password set using SHA256 \"${RABBITMQ_PASSWORD_SHA256}\""
  exit 0
else
  error "could not update password for \"${RABBITMQ_USERNAME}\", exiting.."
  exit 2
fi