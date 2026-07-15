# AI-DLC Demo

**Purpose:** InsightHub — a realistic customer data portal with intentional security risks that form a Wiz toxic combination (Internet → public Cloud Run → over-privileged SA → customer PII data). Demo shows how Wiz findings surface natively to a developer via Wiz MCP in Claude Code/VSCode, with Wiz auto-creating GitHub Issues and @claude providing in-issue remediation.

## Shared context

Cloudflare setup for the `ljarman.dev` account (tokens, zone/account IDs, curl +
Terraform patterns, the Wiz-only WAF exposure pattern, and gotchas) is imported
from a shared reference so it stays a single source of truth across demos:

@~/.claude/shared/cloudflare-ljarman.md

## Secrets

Secrets are in Bitwarden Secrets Manager (BWS), fetched headlessly at use-time —
never committed or echoed.

```sh
export BWS_ACCESS_TOKEN="$(cat ~/.config/wiz-onprem-demo/bws-token)"   # homelab + tars
bws --color no secret get <id> -o json | jq -r .value                  # always --color no before jq
```

## Architecture

**App:** Python FastAPI (`app/`) → Docker image (GCR) → GCP Cloud Run (`ai-dlc-demo`)
**Public URL:** `https://ai-dlc-demo-332394484301.us-central1.run.app` (direct Cloud Run, public)
**Image:** `gcr.io/clgcporg40-p001/ai-dlc-demo/app:latest` (build with `--platform linux/amd64`)

**Intentional risks (the demo story):**
- `app/main.py`: SQL injection in `/api/customers`, hardcoded secrets, unauthenticated export endpoint
- `app/requirements.txt`: `pillow==9.0.0`, `cryptography==36.0.0`, `jinja2==3.0.0` — all have known CVEs
- `app/Dockerfile`: `python:3.9-slim` base (OS CVEs), no USER directive (runs as root)
- `terraform/iam.tf`: SA `ai-dlc-demo-sa` has `roles/editor` + `roles/storage.objectAdmin` at project level
- `terraform/main.tf`: `allUsers` → `roles/run.invoker` (public, no auth)
- `terraform/storage.tf`: GCS bucket with fake PII data, no CMEK, legacy ACL mode

**Toxic combination path Wiz surfaces:**
```
Internet (allUsers)
  → Cloud Run ai-dlc-demo (public, root container, critical CVEs + SQLi)
    → SA ai-dlc-demo-sa (roles/editor + roles/storage.objectAdmin)
      → GCS bucket <project>-customer-data (customers.csv, employees.csv with PII)
```

## GCP Setup

**Auth:** gcloud container in OrbStack — see user for container name and auth steps.
All `gcloud` / `terraform` commands run inside the container.

**GCP auth:** `GOOGLE_APPLICATION_CREDENTIALS=/tmp/gcloud-ailab/adc.json CLOUDSDK_CONFIG=/tmp/gcloud-ailab`
(Credentials live in `/tmp/gcloud-ailab/` — regenerate from `gcloud-gemini` container if expired)

**Terraform apply pattern:**
```sh
GOOGLE_APPLICATION_CREDENTIALS=/tmp/gcloud-ailab/adc.json \
CLOUDSDK_CONFIG=/tmp/gcloud-ailab \
terraform apply
```

**terraform.tfvars (gitignored):**
```hcl
project_id               = "clgcporg40-p001"
region                   = "us-central1"
wiz_sensor_client_id     = "<from BWS wiz-demos/wiz-sensor-client-id>"
wiz_sensor_client_secret = "<from BWS wiz-demos/wiz-sensor-client-secret>"
```

**Image rebuild + redeploy:**
```sh
# Build (always --platform linux/amd64 — built on Apple Silicon)
docker build --platform linux/amd64 -t gcr.io/clgcporg40-p001/ai-dlc-demo/app:latest ./app

# Auth to GCR using the gcloud-gemini container token
SA_TOKEN=$(docker exec gcloud-gemini gcloud auth print-access-token)
echo "$SA_TOKEN" | docker login gcr.io --username oauth2accesstoken --password-stdin
docker push gcr.io/clgcporg40-p001/ai-dlc-demo/app:latest

# Redeploy
docker exec gcloud-gemini gcloud run services update ai-dlc-demo \
  --image gcr.io/clgcporg40-p001/ai-dlc-demo/app:latest \
  --region us-central1 --project clgcporg40-p001
```

## GitHub Integration

**Repository:** `lucasjarman/ai-dlc-demo` (public)
**GH secrets needed for CI:**
- `GCP_PROJECT_ID` — GCP project ID
- `GCP_SA_KEY` — Service account JSON key with Artifact Registry write + Cloud Run deploy permissions
- `WIZ_CLIENT_ID` / `WIZ_CLIENT_SECRET` — Wiz service account for `wizcli image scan` step

**Wiz → GitHub flow:**
1. Wiz GH connector scans repo on push
2. Automation Rule in Wiz portal fires when toxic combination issue created → Wiz GH App creates issue in this repo
3. Issue template tags @claude (Anthropic bot) for in-issue remediation
4. On PR: Wiz bot comments inline findings; `wizcli image scan` in CI links image CVEs to this commit

**Wiz Automation Rule** (configured in Wiz portal — not in this repo):
- Trigger: Issue Created, type = Toxic Combination
- Filter: entitySnapshot.cloudPlatform = "GCP", sourceRuleId matches the toxic combination control
- Action: Create GitHub Issue in `lucasjarman/ai-dlc-demo`

## CI/CD

See `.github/workflows/deploy.yml` — build → wizcli scan → push to Artifact Registry → `gcloud run services update`.
`wizcli docker scan` is run non-blocking (`--exit-code 0`) to report findings without breaking the build (for demo purposes).

## Wiz MCP Demo Script

In Claude Code with Wiz MCP active:
```
"What security risks does Wiz see in this repo?"
"Show me the toxic combination issue and the attack path"
"Fix the SQL injection in app/main.py"
"What CVEs are in the running Cloud Run container?"
"Who owns the affected service account?"
```

## Notes

<!-- Infrastructure status, Cloud Run URL, bucket name — fill in after first terraform apply -->
