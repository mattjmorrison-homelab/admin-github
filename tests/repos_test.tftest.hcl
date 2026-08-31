# Verifies local.repos in branch_protection.tf uses the renamed repo names
# (k8s-*) rather than the stale legacy names (homelab-*, k8s-ci-rbac), per
# the org-wide rename tracked in the companion admin-github PR. Runs fully
# local via a mocked github provider -- no S3 backend, no GitHub token.

mock_provider "github" {}

run "repos_use_renamed_names" {
  command = plan

  variables {
    github_owner = "mattjmorrison-homelab"
  }

  assert {
    condition = alltrue([
      for new_name in [
        "k8s-argocd",
        "k8s-apps",
        "k8s-homepage",
        "k8s-lib-ci-rbac",
        "k8s-alertmanager",
        "k8s-prometheus",
        "k8s-zot",
        "k8s-cert-manager",
        "k8s-cert-manager-config",
        "k8s-cert-manager-crds",
        "k8s-cloudflare",
        "k8s-coredns",
        "k8s-external-secrets",
        "k8s-external-secrets-crds",
        "k8s-grafana",
        "k8s-home-assistant",
        "k8s-kube-state-metrics",
        "k8s-node-exporter",
        "k8s-pihole",
        "k8s-speedtest-exporter",
        "k8s-traefik",
        "k8s-argocd-image-updater",
      ] : contains(local.repos, new_name)
    ])
    error_message = "local.repos is missing one or more renamed repo names."
  }

  assert {
    condition = alltrue([
      for old_name in [
        "homelab-argocd",
        "homelab-apps",
        "homelab-homepage",
        "k8s-ci-rbac",
        "homelab-alertmanager",
        "homelab-prometheus",
        "homelab-zot",
        "homelab-cert-manager",
        "homelab-cert-manager-config",
        "homelab-cert-manager-crds",
        "homelab-cloudflare",
        "homelab-coredns",
        "homelab-external-secrets",
        "homelab-external-secrets-crds",
        "homelab-grafana",
        "homelab-home-assistant",
        "homelab-kube-state-metrics",
        "homelab-node-exporter",
        "homelab-pihole",
        "homelab-speedtest-exporter",
        "homelab-traefik",
        "homelab-argocd-image-updater",
      ] : !contains(local.repos, old_name)
    ])
    error_message = "local.repos still contains one or more stale (pre-rename) repo names."
  }
}
