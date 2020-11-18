#!/bin/bash

set -o nounset

. /opt/bitnami/scripts/libhook.sh

while getopts t:d: flag
do
	case "${flag}" in
	    t) TERMINATION_GRACE_PERIOD_SECONDS=${OPTARG};;
	    d) export BITNAMI_DEBUG=${OPTARG};;
	esac
done

if [[ "${TERMINATION_GRACE_PERIOD_SECONDS:-x}" =~ ^[0-9]+$ ]]; then
    RABBITMQ_SYNC_TIMEOUT=$(($TERMINATION_GRACE_PERIOD_SECONDS - 10))
else
    RABBITMQ_SYNC_TIMEOUT=0
fi

debug "RABBITMQ_SYNC_TIMEOUT is $RABBITMQ_SYNC_TIMEOUT"

if debug_execute rabbitmqctl cluster_status && [[ $RABBITMQ_SYNC_TIMEOUT > 0 ]]; then
    debug "Will wait up to $RABBITMQ_SYNC_TIMEOUT seconds for node to make sure cluster is healthy after node shutdown"
    debug_execute timeout $RABBITMQ_SYNC_TIMEOUT /opt/bitnami/scripts/rabbitmq/waitforsafeshutdown.sh
    if [ $? -eq 124]; then
        warn "Wait for safe node shutdown has timed out. Continuing to node shutdown anyway."
    fi
fi

rabbitmqctl stop_app
