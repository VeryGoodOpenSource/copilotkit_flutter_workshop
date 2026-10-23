# Deploying the shared backend

The shared backend is `runtime/` on Cloud Run, in the Google Cloud project
`gen-lang-client-0563181971`. GitHub Actions deploys it on every change to
`runtime/` on `main` (`.github/workflows/deploy_runtime.yaml`). Pull requests only
typecheck it and build the image (`.github/workflows/runtime_ci.yaml`).

```
push to main ──> GitHub Actions ──(Workload Identity, no key file)──> Google Cloud
                   │ build image ─> Artifact Registry ─> Cloud Run
                   │                                       ▲ ANTHROPIC_API_KEY, WORKSHOP_CODE
                   │                                       │ (GitHub repository secrets)
                   └ smoke test: /info is open, a run without the code is 401
```

## Where each value lives

| Value | Lives in | Why |
| --- | --- | --- |
| `ANTHROPIC_API_KEY` | GitHub secret | The workflow passes it to Cloud Run as an environment variable. |
| `WORKSHOP_CODE` | GitHub secret | Same. Use letters and digits only: the value is passed in a comma-separated list. |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | GitHub secret | Tells the job which identity provider to sign in with. |
| `GCP_SERVICE_ACCOUNT` | GitHub secret | The account the job acts as. |

GitHub masks the secrets in the logs and they are never in the image. Cloud Run
shows environment variables in the revision's settings, though, so anyone with
view access to the Google Cloud project can read them there. Keep that access
small, or move the two values to Secret Manager if it ever grows.

No Google key file exists anywhere. The provider only accepts tokens from this
repository on `main`.

## Steps

**1. Sign in** with an account that owns the project:

```sh
gcloud auth login
```

**2. Run the setup once.** It enables the APIs, creates the registry, the two
service accounts and the Workload Identity provider, and it is safe to run
again. It creates no secret and asks for nothing:

```sh
bash runtime/deploy/setup_gcp.sh
```

**3. Add the four GitHub secrets**, in the repository's *Settings → Secrets and
variables → Actions*, or with the GitHub CLI (`gh auth login` first). The script
prints the first two values. The last two commands ask for the value and hide it:

```sh
gh secret set GCP_WORKLOAD_IDENTITY_PROVIDER --repo VeryGoodOpenSource/copilotkit_flutter_workshop
gh secret set GCP_SERVICE_ACCOUNT            --repo VeryGoodOpenSource/copilotkit_flutter_workshop
gh secret set ANTHROPIC_API_KEY              --repo VeryGoodOpenSource/copilotkit_flutter_workshop
gh secret set WORKSHOP_CODE                  --repo VeryGoodOpenSource/copilotkit_flutter_workshop
```

For a password, `openssl rand -hex 5` gives ten letters and digits.

**4. Deploy.** Merge to `main`, or run it by hand: *Actions → deploy_runtime →
Run workflow* (`gh workflow run deploy_runtime.yaml`). The last step of the job
prints the URL and fails if the password gate is not on.

**5. Point the workshop at it.** Set `sharedBackendUrl` in
`tool/workshop.config.json` to the URL ending in `/api/copilotkit`, and check it:

```sh
node tool/doctor.mjs --only backend --backend <url>
```

**6. Hand out the password** at the workshop. Participants give it to
`node tool/setup.mjs --code <password>` (or type it when asked).

## Operating it

- **Rotate the password or the key:** `gh secret set WORKSHOP_CODE` (or
  `ANTHROPIC_API_KEY`), then run the workflow again so a new revision picks it up.
- **Turn it off after the workshop:** `gcloud run services delete calaverita-runtime --region us-central1`,
  or revoke the Anthropic key. The deployment costs nothing while idle.
- **One instance on purpose** (`--max-instances=1`): the runtime keeps threads in
  memory, and a second instance would not know them. For a large room, raise the
  limit only after moving the threads out of memory.
- **Cold starts:** the first message after a quiet period takes a few seconds. Add
  `--min-instances=1` to the `flags` in the workflow during the workshop to avoid it.
- **Logs:** `gcloud run services logs read calaverita-runtime --region us-central1`.
