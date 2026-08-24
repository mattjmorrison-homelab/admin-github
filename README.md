# admin-github

OpenTofu config managing the `mattjmorrison-homelab` GitHub org, using the
[`integrations/github`](https://registry.terraform.io/providers/integrations/github/latest)
provider. See `naming.md`'s `admin-` prefix for why this repo exists — its
destination is the GitHub org/API itself, not a machine or the cluster.
The OpenBao KV path (`kv/homelab/gh-org`) and Kubernetes Secret
(`gh-org-github-token`) this repo's CI reads from don't match this repo's
own name — internal identifiers, not required to track it, and due for
restructuring anyway by the planned `admin-openbao` migration to
one-secret-per-path.

## What this manages

- `repository.tf` — every repo in the org (`github_repository`,
  `visibility = "public"`, `prevent_destroy` guarded so removing a name
  from the list can't delete a real repo by accident).
- `branch_protection.tf` — protects `main` on every repo in the org:
  requires a pull request with at least one approving review, no force
  pushes, and (via `enforce_admins`) no exceptions for org owners either.

Applied per repo via the classic `github_branch_protection` resource
rather than an org-wide ruleset, because org-wide rulesets are only
enforced on a GitHub Team/Enterprise plan — confirmed not enforced on this
org's current Free plan. Per-repo branch protection isn't plan-gated.

State lives in `k8s-garage`'s `tofu-state` bucket (see `provider.tf`'s
`backend "s3"` block), not locally — required for CI, since each run gets
a fresh pod with no local state otherwise.

## Local usage

Auth: the provider and the S3 backend both read credentials from env
vars. For a human running this locally, your own `gh` session's token is
enough:

```sh
export GITHUB_TOKEN=$(gh auth token)
export AWS_ACCESS_KEY_ID=<TOFU_STATE_ACCESS_KEY_ID from kv/homelab/gh-org>
export AWS_SECRET_ACCESS_KEY=<TOFU_STATE_SECRET_ACCESS_KEY from kv/homelab/gh-org>
tofu init
tofu plan
tofu apply
```

The S3 endpoint (`garage.garage.svc.cluster.local:3900`) is only
reachable from inside the cluster — from a machine outside it, add
`kubectl port-forward -n garage svc/garage 3900:3900` and override the
endpoint to `http://localhost:3900` for the session (a `backend "s3" {
endpoints = { s3 = "http://localhost:3900" } }` block in a temporary
`*_override.tf` file, not committed).

## Adding a new repo

Add its name to the `repos` set in `branch_protection.tf`, then
`tofu apply`.

## CI

`.woodpecker.yml` runs `tofu plan` on every push/PR, and `tofu apply` on
push to `main` — which, once branch protection is actually applied to
this repo itself, only happens via a merged PR.

### What the GitHub App needs

CI authenticates as a GitHub App (`repo-admin` in the [access control
proposal](https://github.com/mattjmorrison-homelab/.github/blob/main/docs/github-access-control-proposal.md)),
not a personal token — full design rationale is in that doc; this is the
exact setup.

**Register the App** (org Settings → Developer settings → GitHub Apps →
New GitHub App), on `mattjmorrison-homelab`, with:

- **Organization permissions**
  - `Administration`: **Read and write** — repo creation/rename
  - `Members`: **Read and write** — org/team membership for the PR bot,
    managed from this same repo
- **Repository permissions**
  - `Administration`: **Read and write** — branch protection, rulesets,
    required status checks, repo settings
- No other permissions — no `Contents`, `Pull requests`, `Metadata`, etc.
  This App reshapes repo/org structure; it can't read or write code.

**Install** it on `mattjmorrison-homelab`, scoped to all repositories (or
all current ones plus a habit of adding new ones as they're created).

**Three things end up in OpenBao** (`kv/homelab/gh-org`), none of them a
static long-lived token:

- `github_app_id` — the App's numeric ID (shown on its settings page)
- `github_app_installation_id` — the installation's numeric ID (from the
  URL when viewing the installation, or `GET /orgs/mattjmorrison-homelab/installation`)
- `github_app_private_key` — the `.pem` generated on the App's settings
  page (**Generate a private key**)

**Minting a token in CI** (what a step in `.woodpecker.yml` needs to do
before `tofu` runs): sign a JWT (RS256, `iss` = App ID, `iat` = now minus
60s for clock drift, `exp` = at most 10 minutes from `iat`) with the
private key, then `POST
https://api.github.com/app/installations/{installation_id}/access_tokens`
with `Authorization: Bearer <jwt>`, which returns a `{"token": ...}` valid
for about an hour. Export that as `GITHUB_TOKEN` for the rest of the
pipeline. Not yet wired into `.woodpecker.yml` — currently still using a
personal fine-grained PAT in `kv/homelab/gh-org`'s `github_token`, which
the proposal doc flags for revocation once this is live.
