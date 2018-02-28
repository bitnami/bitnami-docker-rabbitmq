#!/bin/bash -e

. /opt/bitnami/base/functions
. /opt/bitnami/base/helpers

print_welcome_page

if [[ "${RABBIT_ULIMIT}" ]]; then
    ulimit -n "${RABBIT_ULIMIT}"
else
    ulimit -n 1024
fi

if [[ "$1" == "nami" && "$2" == "start" ]] || [[ "$1" == "/init.sh" ]]; then
  nami_initialize rabbitmq
  info "Starting rabbitmq... "
fi

exec tini -- "$@"
