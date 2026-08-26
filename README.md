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

`.github/workflows/tofu.yml` runs on this org's self-hosted GitHub
Actions runners (`k8s-amd64`, from `k8s-github-runner`): a `check` job on
every PR (`tofu fmt -check`, `tflint`, `tofu plan -out=tfplan`, uploaded
as an artifact), and an `apply` job that runs only once a PR is merged —
downloading that exact plan artifact and applying it directly, never
re-planning at merge time, so what gets applied is always identical to
what was reviewed. The shared steps (fetching credentials from OpenBao,
finding the matching plan artifact) live in
[`actions-tofu`](https://github.com/mattjmorrison-homelab/actions-tofu)
as composite actions, not duplicated here — same ones `admin-openbao`
uses.

Branch protection on this repo's own `main` requires `check` to pass and
1 approving review, same as every other repo `local.repos` covers.

### Authentication

CI authenticates to the GitHub API with a personal fine-grained PAT
(`kv/homelab/admin-github/github-token` in OpenBao), fetched at runtime
via `actions-tofu`'s `fetch-credentials` action — not a GitHub App. A
GitHub App-based design was proposed (see the [access control
proposal](https://github.com/mattjmorrison-homelab/.github/blob/main/docs/github-access-control-proposal.md))
but never built; the PAT is what's actually live today.
