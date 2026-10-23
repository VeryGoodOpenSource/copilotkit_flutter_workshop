#!/usr/bin/env bash
# One-time Google Cloud setup for the shared backend. Safe to run again.
#
#   gcloud auth login
#   bash runtime/deploy/setup_gcp.sh
#
# It creates no secret: the Anthropic key (CLAUDE_API_KEY) and the workshop
# password are GitHub repository secrets. See runtime/deploy/README.md for what each step is for.
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
  run.googleapis.com artifactregistry.googleapis.com \
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
# run.admin, not run.developer: the first deploy sets the service public.
gc projects add-iam-policy-binding "$PROJECT" \
  --member "serviceAccount:$DEPLOYER_EMAIL" --role roles/run.admin --condition=None >/dev/null
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

step "Done. Add these four secrets to GitHub (Settings > Secrets and variables > Actions):"
cat <<OUT

  GCP_WORKLOAD_IDENTITY_PROVIDER = $PROVIDER_NAME
  GCP_SERVICE_ACCOUNT            = $DEPLOYER_EMAIL
  CLAUDE_API_KEY                 = your Anthropic key
  WORKSHOP_CODE                  = the password for the participants (letters and digits)

or, with the GitHub CLI (the last two ask for the value, hidden):

  gh secret set GCP_WORKLOAD_IDENTITY_PROVIDER --repo $GITHUB_REPO --body "$PROVIDER_NAME"
  gh secret set GCP_SERVICE_ACCOUNT --repo $GITHUB_REPO --body "$DEPLOYER_EMAIL"
  gh secret set CLAUDE_API_KEY --repo $GITHUB_REPO
  gh secret set WORKSHOP_CODE --repo $GITHUB_REPO

After the first deploy the backend answers at:

  https://$SERVICE-$PROJECT_NUMBER.$REGION.run.app/api/copilotkit

OUT
