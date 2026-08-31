# Repos currently in the org (`gh repo list mattjmorrison-homelab`). Add
# new repos here as they're created — see the README's "Adding a new
# repo" and "Renaming a repo already in local.repos" sections for the
# exact steps. Getting the ordering wrong (old and new name both present
# at once, or this list keyed differently than Terraform state) can
# hard-fail `tofu plan` or silently destroy+recreate real branch
# protection.
locals {
  repos = toset([
    # Meta Repo
    ".github",

    # Admin repos
    "admin-github",
    "admin-openbao",
    "admin-network",

    # Github Actions repos
    "actions-bash",
    "actions-helm",
    "actions-tofu",

    # AI Repos
    "ai-claude",

    # Graphql Repos
    "graph-hdmi-switch",
    "graph-health",
    "graph-router",

    # k8s repos
    # k8s-lib-ci-rbac: a reusable Helm library chart — see
    # .github/docs/rbac-plan.md.
    "k8s-lib-ci-rbac",
    "k8s-github-runner",
    "k8s-openbao",
    "k8s-garage",
    "k8s-graphql-router",
    "k8s-hdmi-switch",
    "k8s-health",
    "k8s-matter-server",

    # Raspberry Pi Repos
    "pi-health",
    "pi-provision",

    # Steamos Repos
    "steamos-provision",

    # Web App Repos
    "ui-hdmi-switch",

    # Legacy names — these two are deliberately not renamed.
    # homelab-woodpecker is being retired outright, not renamed (its
    # Application entry gets removed and the repo archived once nothing
    # depends on it anymore) — see .github/docs/rbac-plan.md. homelab's
    # own rename to nix-control-plane is part of the broader org-wide
    # renaming initiative in .github/docs/naming.md, which hasn't been
    # greenlit to execute yet.
    "homelab",
    "homelab-woodpecker",

    # k8s repos, renamed from their legacy homelab-* names — see
    # naming.md's rename mapping and PR #10
    # (https://github.com/mattjmorrison-homelab/admin-github/pull/10).
    "k8s-alertmanager",
    "k8s-apps",
    "k8s-argocd",
    "k8s-argocd-image-updater",
    "k8s-cert-manager",
    "k8s-cert-manager-config",
    "k8s-cert-manager-crds",
    "k8s-cloudflare",
    "k8s-coredns",
    "k8s-external-secrets",
    "k8s-external-secrets-crds",
    "k8s-grafana",
    "k8s-home-assistant",
    "k8s-homepage",
    "k8s-kube-state-metrics",
    "k8s-node-exporter",
    "k8s-pihole",
    "k8s-prometheus",
    "k8s-speedtest-exporter",
    "k8s-traefik",
    "k8s-zot",
  ])
}

# Every repo in local.repos is required to have a passing "check" before
# merge -- no opt-out. Don't uncomment a repo above until it actually has
# a "check" job in its own CI, or its PRs become permanently unmergeable.
locals {
  required_checks = {
    for repo in local.repos : repo => ["check"]
  }
}

# Org-wide rulesets would cover this in one resource, but GitHub only
# enforces those on a Team/Enterprise plan (confirmed against this org on
# Free) — so protection is applied per repo instead via the classic
# branch_protection resource, which isn't plan-gated.
resource "github_branch_protection" "main" {
  for_each = local.repos

  repository_id = github_repository.repos[each.value].name
  pattern       = "main"

  required_pull_request_reviews {
    required_approving_review_count = 1
  }

  # strict = true requires the branch be up to date with main before
  # merging, for every repo -- cheap safety net even where no check is
  # named below, and for admin-openbao it's what forces a stale PR to
  # re-run `plan` (via a fresh `synchronize` event) before it can merge,
  # so the plan artifact applied at merge time is never stale.
  required_status_checks {
    strict   = true
    contexts = lookup(local.required_checks, each.value, [])
  }

  allows_force_pushes = false
  enforce_admins      = true
}
