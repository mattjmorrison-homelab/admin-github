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

## Renaming a repo already in `local.repos`

GitHub keeps the old name working as a redirect to the same real repo
after a rename — `gh api repos/OWNER/OLD_NAME --jq '.name'` returns the
*new* name if this has already happened. That matters here because
Terraform doesn't know the two names are the same repo: if both the old
and new name ever end up in `local.repos` at once, `tofu plan` treats
them as two separate resources targeting one real repo, and
`github_branch_protection`'s create fails outright ("Name already
protected: main") the moment the second one tries to apply. Learned this
the hard way with `homelab-openbao` → `k8s-openbao`.

The steps, in order:

1. Rename the repo on GitHub first (Settings → repo name). Confirm it
   actually moved: `gh api repos/OWNER/OLD_NAME --jq '.name'` should
   print the new name.
2. In `local.repos`: add the new name, remove the old name, in the same
   commit — never have both at once.
3. This leaves two stale entries in Terraform's state file under the old
   name: `github_repository.repos["OLD_NAME"]` and
   `github_branch_protection.main["OLD_NAME"]`. Once the old key is gone
   from `local.repos`, `tofu plan` wants to *destroy* both — for
   `github_repository` that's blocked by `prevent_destroy` (good, it
   would otherwise call GitHub's real delete-repo API against the repo
   both names point to); for `github_branch_protection` there's no such
   guard, so left unaddressed it would call the real
   remove-branch-protection API before the new name's own entry has a
   chance to be the sole owner.
4. Fix: drop both from state, without touching real infrastructure —
   ```sh
   tofu state rm 'github_repository.repos["OLD_NAME"]'
   tofu state rm 'github_branch_protection.main["OLD_NAME"]'
   ```
   This only edits the state file; no API calls happen. A `removed`
   block looks like the declarative way to express this, but doesn't
   work here — it only supports removing an entire resource block, not
   one instance out of a `for_each` (confirmed by OpenTofu's own error:
   "Resource address cannot be a resource instance"). `state rm` is the
   only tool that operates at single-instance granularity.
5. Running `state rm` needs real backend credentials against the S3
   (Garage) backend — see "Local usage" above for the env vars and the
   port-forward/override needed from outside the cluster. If that's too
   much friction, temporarily add the same two commands (with `|| true`,
   so it's harmless if already clean) into `check`'s existing steps
   right after `tofu init` — `check` already runs on every PR, so this
   doesn't need a new trigger type or a merge first. Remove the lines
   again once the state is clean.
6. To confirm real branch protection status (not just what's in state),
   use `gh api repos/OWNER/REPO/branches/main --jq '.protected'` — the
   classic `/branches/main/protection` endpoint and GraphQL's
   `branchProtectionRules` can both come back empty/404 even when
   protection genuinely exists, for reasons unrelated to whether it's
   actually there (a real false negative hit during this exact rename
   cleanup). The plain `protected` boolean on the branch object itself
   is the one that's actually reliable.

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
