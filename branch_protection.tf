# Repos currently in the org (`gh repo list mattjmorrison-homelab`, captured
# 2026-08-19, plus admin-github and k8s-garage once they're pushed). Add
# new repos here as they're created.
#
# Everything but admin-openbao is commented out for now -- this is a brand
# new, never-applied repo, being used to import the existing repos as-is
# and prove out branch protection on admin-openbao first before rolling it
# out to everything else. Uncomment the rest once that's verified.
locals {
  repos = toset([
    # Meta Repo
    ".github",

    # Admin repos
    "admin-github",
    "admin-openbao",
    "admin-network",

    # Github Actions repos
    "actions-helm",
    "actions-tofu",

    # AI Repos
    "ai-claude",

    # Graphql Repos
    "graph-hdmi-switch",
    "graph-health",
    "graph-router",

    # k8s repos
    "k8s-ci-rbac",
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

    # Legacy names
    "homelab",
    "homelab-alertmanager",
    "homelab-apps",
    "homelab-argocd",
    "homelab-argocd-image-updater",
    "homelab-cert-manager",
    "homelab-cert-manager-config",
    "homelab-cert-manager-crds",
    "homelab-cloudflare",
    "homelab-coredns",
    "homelab-external-secrets",
    "homelab-external-secrets-crds",
    "homelab-grafana",
    "homelab-home-assistant",
    "homelab-homepage",
    "homelab-kube-state-metrics",
    "homelab-node-exporter",
    "homelab-openbao",
    "homelab-pihole",
    "homelab-prometheus",
    "homelab-speedtest-exporter",
    "homelab-traefik",
    "homelab-woodpecker",
    "homelab-zot",
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
