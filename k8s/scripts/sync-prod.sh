#!/usr/bin/env bash
# sync-prod.sh — Emergency: sync prod ArgoCD apps. Replace REPO/APP names before use.
set -euo pipefail

ARGOCD_SERVER=${ARGOCD_SERVER:-argocd.example.com}
ARGOCD_APP=${ARGOCD_APP:-kafka}

echo "Syncing ArgoCD app ${ARGOCD_APP} on ${ARGOCD_SERVER} (placeholder)"
# argocd login $ARGOCD_SERVER --username admin --password ...
# argocd app sync ${ARGOCD_APP} --prune
