#!/usr/bin/env bash
# One-time Google Cloud setup for the shared backend. Safe to run again.
#
#   gcloud auth login
#   bash runtime/deploy/setup_gcp.sh
#
# The Anthropic key and the workshop password live in Secret Manager, and Cloud Run
# reads them as the runtime service account. Pass them as ANTHROPIC_API_KEY and
# WORKSHOP_CODE in the environment, or let the script ask (the input is hidden).
# To change one later, run the script again with the new value.
#
# Run it again after the first deploy: only then does the service exist, and the
# script makes it public (see step 6).
set -euo pipefail

PROJECT="${PROJECT:-gen-lang-client-0563181971}"
REGION="${REGION:-us-central1}"
GITHUB_REPO="${GITHUB_REPO:-VeryGoodOpenSource/copilotkit_flutter_workshop}"
SERVICE="calaverita-runtime"
REGISTRY="calaverita"
POOL="github"
PROVIDER="github-oidc"
DEPLOYER="github-deployer"
RUNTIME_SA="calaverita-runtime"

gc() { gcloud --project "$PROJECT" "$@"; }
step() { printf '\n\033[1m%s\033[0m\n' "$*"; }

step "1. Enabling the APIs"
gc services enable \
  run.googleapis.com artifactregistry.googleapis.com secretmanager.googleapis.com \
  iam.googleapis.com iamcredentials.googleapis.com sts.googleapis.com \
  cloudresourcemanager.googleapis.com

PROJECT_NUMBER="$(gc projects describe "$PROJECT" --format='value(projectNumber)')"
DEPLOYER_EMAIL="$DEPLOYER@$PROJECT.iam.gserviceaccount.com"
RUNTIME_EMAIL="$RUNTIME_SA@$PROJECT.iam.gserviceaccount.com"

step "2. Artifact Registry repository for the image"
gc artifacts repositories describe "$REGISTRY" --location "$REGION" >/dev/null 2>&1 \
  || gc artifacts repositories create "$REGISTRY" --repository-format docker --location "$REGION" \
       --description "Calaverita workshop runtime"

step "3. Service accounts"
# The one the runtime runs as. It has no roles on purpose: the runtime only calls
# Anthropic, and the default account would carry the project's Editor role.
gc iam service-accounts describe "$RUNTIME_EMAIL" >/dev/null 2>&1 \
  || gc iam service-accounts create "$RUNTIME_SA" --display-name "Calaverita runtime"
# The one GitHub Actions deploys with.
gc iam service-accounts describe "$DEPLOYER_EMAIL" >/dev/null 2>&1 \
  || gc iam service-accounts create "$DEPLOYER" --display-name "GitHub deployer"

step "4. What the deployer may do"
gc artifacts repositories add-iam-policy-binding "$REGISTRY" --location "$REGION" \
  --member "serviceAccount:$DEPLOYER_EMAIL" --role roles/artifactregistry.writer >/dev/null
# run.developer deploys revisions but cannot change who may call the service (step 6).
gc projects add-iam-policy-binding "$PROJECT" \
  --member "serviceAccount:$DEPLOYER_EMAIL" --role roles/run.developer --condition=None >/dev/null
# Earlier versions of this script gave the deployer run.admin; take it back.
gc projects remove-iam-policy-binding "$PROJECT" \
  --member "serviceAccount:$DEPLOYER_EMAIL" --role roles/run.admin --condition=None >/dev/null 2>&1 || true
gc iam service-accounts add-iam-policy-binding "$RUNTIME_EMAIL" \
  --member "serviceAccount:$DEPLOYER_EMAIL" --role roles/iam.serviceAccountUser >/dev/null

step "5. Workload Identity Federation: GitHub signs in without a key file"
gc iam workload-identity-pools describe "$POOL" --location global >/dev/null 2>&1 \
  || gc iam workload-identity-pools create "$POOL" --location global --display-name "GitHub Actions"
gc iam workload-identity-pools providers describe "$PROVIDER" --workload-identity-pool "$POOL" --location global >/dev/null 2>&1 \
  || gc iam workload-identity-pools providers create-oidc "$PROVIDER" \
       --workload-identity-pool "$POOL" --location global \
       --issuer-uri "https://token.actions.githubusercontent.com" \
       --attribute-mapping "google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.ref=assertion.ref" \
       --attribute-condition "assertion.repository == '$GITHUB_REPO' && assertion.ref == 'refs/heads/main'"
gc iam service-accounts add-iam-policy-binding "$DEPLOYER_EMAIL" \
  --role roles/iam.workloadIdentityUser \
  --member "principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/$POOL/attribute.repository/$GITHUB_REPO" >/dev/null

PROVIDER_NAME="$(gc iam workload-identity-pools providers describe "$PROVIDER" --workload-identity-pool "$POOL" --location global --format='value(name)')"

step "6. Secrets in Secret Manager"
# Create the secret, let the runtime service account read it, and add a version when given a value.
store_secret() {
  local name="$1" value="${2:-}"
  gc secrets describe "$name" >/dev/null 2>&1 || gc secrets create "$name" --replication-policy automatic >/dev/null
  gc secrets add-iam-policy-binding "$name" \
    --member "serviceAccount:$RUNTIME_EMAIL" --role roles/secretmanager.secretAccessor >/dev/null
  if [ -z "$value" ] && ! gc secrets versions list "$name" --limit 1 --format='value(name)' | grep -q .; then
    read -rsp "Value of $name (hidden): " value; echo
  fi
  if [ -n "$value" ]; then printf '%s' "$value" | gc secrets versions add "$name" --data-file=- >/dev/null; fi
}
store_secret anthropic-api-key "${ANTHROPIC_API_KEY:-}"
store_secret workshop-code "${WORKSHOP_CODE:-}"

step "7. Who may call the service"
# The deployer cannot do this itself, so it happens here, once the service exists.
if gc run services describe "$SERVICE" --region "$REGION" >/dev/null 2>&1; then
  gc run services add-iam-policy-binding "$SERVICE" --region "$REGION" \
    --member allUsers --role roles/run.invoker >/dev/null
  echo "The service is public (the workshop password still guards it)."
else
  echo "The service does not exist yet. Deploy once, then run this script again to make it public."
fi

step "Done. Add these two secrets to GitHub (Settings > Secrets and variables > Actions):"
cat <<OUT

  GCP_WORKLOAD_IDENTITY_PROVIDER = $PROVIDER_NAME
  GCP_SERVICE_ACCOUNT            = $DEPLOYER_EMAIL

or, with the GitHub CLI:

  gh secret set GCP_WORKLOAD_IDENTITY_PROVIDER --repo $GITHUB_REPO --body "$PROVIDER_NAME"
  gh secret set GCP_SERVICE_ACCOUNT --repo $GITHUB_REPO --body "$DEPLOYER_EMAIL"

The Anthropic key and the workshop password are not GitHub secrets any more: they are
in Secret Manager (anthropic-api-key, workshop-code). The old repository secrets
ANTHROPIC_API_KEY (and CLAUDE_API_KEY) and WORKSHOP_CODE can be deleted.

After the first deploy the backend answers at:

  https://$SERVICE-$PROJECT_NUMBER.$REGION.run.app/api/copilotkit

OUT
