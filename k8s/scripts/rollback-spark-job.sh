#!/usr/bin/env bash
# rollback-spark-job.sh — rollback a SparkApplication to a previous revision (placeholder)
set -euo pipefail

APP_NAME=${1:-my-spark-app}
NAMESPACE=${2:-spark-jobs}
REVISION=${3:-previous}

echo "Rolling back ${APP_NAME} in ${NAMESPACE} to ${REVISION} (placeholder)"
# kubectl rollout undo sparkapplication/${APP_NAME} -n ${NAMESPACE} --to-revision=${REVISION}
