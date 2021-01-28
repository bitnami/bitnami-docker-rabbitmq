#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitnami/scripts/libbitnami.sh
. /opt/bitnami/scripts/librabbitmq.sh
. /opt/bitnami/scripts/liblog.sh

# Load RabbitMQ environment variables
. /opt/bitnami/scripts/rabbitmq-env.sh

print_welcome_page

if [[ "$*" = "/opt/bitnami/scripts/rabbitmq/run.sh" ]]; then
    # Be sure the setup flag is removed (if someone make RABBITMQ_LIB_DIR persistent)
    rm -f "${RABBITMQ_LIB_DIR}/.setup-completed" 2>/dev/null

    info "** Starting RabbitMQ setup **"
    /opt/bitnami/scripts/rabbitmq/setup.sh
    info "** RabbitMQ setup finished! **"

    # Create a setup completed flag.
    # Since setup.sh can fully boot the rabbit node, this one can join the cluster,
    # starts to work and be shutdown right after causing troubles
    # To avoid this we would like the K8S probes to detect the node up&running only
    # after the node booted the 2nd time (not booted before the setup as ran)
    touch "${RABBITMQ_LIB_DIR}/.setup-completed"
fi

echo ""
exec "$@"
