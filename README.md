# admin-github

## ⚠ DO NOT MERGE ANY PR HERE UNTIL THIS SECTION IS REMOVED (as of 2026-08-31)

This repo's Terraform state does not match live GitHub reality right now,
following a real incident: `local.repos` had every renamed repo's old name,
so an unrelated merge (PR #8) triggered `tofu apply` to revert 22 already-
renamed repos back to their old GitHub names. State was partially repaired
via `tofu state mv` (PR #10, already merged, workflow already run), and all
22 repos (plus `k8s-ci-rbac`→`k8s-lib-ci-rbac`, renamed separately/manually,
**not yet reflected in Terraform state at all**) are now correctly renamed
live on GitHub — confirmed via direct API audit.

**Two PRs are open and must NOT be merged as-is:**
- **#9** (`add-k8s-host-rbac-repo`) — adds a new repo to `local.repos`;
  looks unrelated but touches the same list, so merging it while state is
  still drifted risks re-triggering the same class of incident.
- **#11** (`update-local-repos-renamed-names`) — updates `local.repos` to
  the new names. Its branch also has an uncommitted `lifecycle {
  create_before_destroy = true }` change on `github_branch_protection.main`
  that was added, then found to likely break `tofu apply` outright (GitHub
  only allows one `main`-pattern protection rule per repo, so create-before-
  destroy collides with the still-live old rule) — never reverted before
  the session that found this ended. Don't build on this branch as-is.

**Agreed plan, not yet executed:** rather than keep patching `state mv`/
lifecycle workarounds, delete Terraform's state for the affected resources
(`github_repository.repos` + `github_branch_protection.main`, per repo) and
re-baseline cleanly with `import` blocks against current live reality (which
now already matches the desired `k8s-*` names) — a fresh import never
computes a destroy/replace diff, since nothing needs to change. Open
question, never answered: scope this to just the ~23 affected repos, or all
46 for a fully clean baseline. Full context: this README's own "Renaming a
repo already in `local.repos`" section below, and PRs #9/#10/#11's
descriptions.

---

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
  from the list can't delete a real repo by accident). `auto_init = true`
  so newly-created repos start with a README and a default branch
  instead of being created completely empty — an empty repo has no
  branch for `github_branch_protection.main` to attach to, so this
  avoids a chicken-and-egg failure the first time a new name is applied.
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

## State recovery after mass rename incident (one-time fix)

`scripts/fix-repo-rename-state.sh` and its manually-triggered workflow
(`.github/workflows/fix-repo-rename-state.yml`) re-key Terraform state
from old repo names to new names — a state-only operation, no GitHub API
calls. This fixes a situation where Terraform state entries are keyed by
old names (e.g. `github_repository.repos["homelab-argocd"]`) after repos
have been renamed on GitHub, causing `tofu plan` to see the new names as
missing resources and old names as orphaned, which would trigger
destroy+create cycles.

After manually running the workflow once via GitHub's Actions UI and
confirming state recovery is complete, delete the script and workflow
from the repo — they are one-time tools, not permanent.

**CRITICAL:** The follow-up PR that updates `local.repos` to the new
names must merge IMMEDIATELY after the state recovery workflow completes,
with NO other admin-github PR merged in between. During the window after
`state mv` runs but before `local.repos` is updated, Terraform state and
config are keyed differently (state uses NEW names, config still has OLD
names). If any other PR triggers a `tofu apply` in that gap,
`github_repository.repos` will hard-fail under `prevent_destroy` (Terraform
would see the new-keyed resource as orphaned), and `github_branch_protection.main`
will silently destroy and recreate itself. Merge the follow-up PR
immediately to close this window.

The `github_branch_protection.main` re-keying is precautionary, for
consistency with the repository re-keying. Branch protection on these
repos does genuinely exist on GitHub (confirmed via direct API audit with
real admin credentials — required reviews, required status checks, the
works), so this re-keying matters for avoiding a real destroy+create
cycle, not a phantom one.

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
