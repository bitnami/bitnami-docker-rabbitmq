#!/bin/bash -e

. /opt/bitnami/base/functions
. /opt/bitnami/base/helpers

print_welcome_page

if [[ "$1" == "nami" && "$2" == "start" ]] || [[ "$1" == "/init.sh" ]]; then
  . /init.sh
  nami_initialize rabbitmq
  info "Starting rabbitmq... "
  /set_sha256_passwd.sh --sleep 5 1>&2 >/dev/stderr &
  disown
fi

exec tini -- "$@"
