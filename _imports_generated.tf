# GENERATED — one-time re-baseline import file.
# Delete this file after `tofu apply` succeeds; not meant to persist.
#
# Precondition: state for github_repository.repos[*] and
# github_branch_protection.main[*] has been fully cleared (see README
# incident notes) before this is planned/applied — otherwise these
# import blocks collide with existing state entries under the same
# address.

import {
  to = github_repository.repos["actions-bash"]
  id = "actions-bash"
}

import {
  to = github_branch_protection.main["actions-bash"]
  id = "actions-bash:main"
}

import {
  to = github_repository.repos["actions-helm"]
  id = "actions-helm"
}

import {
  to = github_branch_protection.main["actions-helm"]
  id = "actions-helm:main"
}

import {
  to = github_repository.repos["actions-tofu"]
  id = "actions-tofu"
}

import {
  to = github_branch_protection.main["actions-tofu"]
  id = "actions-tofu:main"
}

import {
  to = github_repository.repos["admin-github"]
  id = "admin-github"
}

import {
  to = github_branch_protection.main["admin-github"]
  id = "admin-github:main"
}

import {
  to = github_repository.repos["admin-network"]
  id = "admin-network"
}

import {
  to = github_branch_protection.main["admin-network"]
  id = "admin-network:main"
}

import {
  to = github_repository.repos["admin-openbao"]
  id = "admin-openbao"
}

import {
  to = github_branch_protection.main["admin-openbao"]
  id = "admin-openbao:main"
}

import {
  to = github_repository.repos["ai-claude"]
  id = "ai-claude"
}

import {
  to = github_branch_protection.main["ai-claude"]
  id = "ai-claude:main"
}

import {
  to = github_repository.repos[".github"]
  id = ".github"
}

import {
  to = github_branch_protection.main[".github"]
  id = ".github:main"
}

import {
  to = github_repository.repos["graph-hdmi-switch"]
  id = "graph-hdmi-switch"
}

import {
  to = github_branch_protection.main["graph-hdmi-switch"]
  id = "graph-hdmi-switch:main"
}

import {
  to = github_repository.repos["graph-health"]
  id = "graph-health"
}

import {
  to = github_branch_protection.main["graph-health"]
  id = "graph-health:main"
}

import {
  to = github_repository.repos["graph-router"]
  id = "graph-router"
}

import {
  to = github_branch_protection.main["graph-router"]
  id = "graph-router:main"
}

import {
  to = github_repository.repos["homelab"]
  id = "homelab"
}

import {
  to = github_branch_protection.main["homelab"]
  id = "homelab:main"
}

import {
  to = github_repository.repos["homelab-woodpecker"]
  id = "homelab-woodpecker"
}

import {
  to = github_branch_protection.main["homelab-woodpecker"]
  id = "homelab-woodpecker:main"
}

import {
  to = github_repository.repos["k8s-alertmanager"]
  id = "k8s-alertmanager"
}

import {
  to = github_branch_protection.main["k8s-alertmanager"]
  id = "k8s-alertmanager:main"
}

import {
  to = github_repository.repos["k8s-apps"]
  id = "k8s-apps"
}

import {
  to = github_branch_protection.main["k8s-apps"]
  id = "k8s-apps:main"
}

import {
  to = github_repository.repos["k8s-argocd"]
  id = "k8s-argocd"
}

import {
  to = github_branch_protection.main["k8s-argocd"]
  id = "k8s-argocd:main"
}

import {
  to = github_repository.repos["k8s-argocd-image-updater"]
  id = "k8s-argocd-image-updater"
}

import {
  to = github_branch_protection.main["k8s-argocd-image-updater"]
  id = "k8s-argocd-image-updater:main"
}

import {
  to = github_repository.repos["k8s-cert-manager"]
  id = "k8s-cert-manager"
}

import {
  to = github_branch_protection.main["k8s-cert-manager"]
  id = "k8s-cert-manager:main"
}

import {
  to = github_repository.repos["k8s-cert-manager-config"]
  id = "k8s-cert-manager-config"
}

import {
  to = github_branch_protection.main["k8s-cert-manager-config"]
  id = "k8s-cert-manager-config:main"
}

import {
  to = github_repository.repos["k8s-cert-manager-crds"]
  id = "k8s-cert-manager-crds"
}

import {
  to = github_branch_protection.main["k8s-cert-manager-crds"]
  id = "k8s-cert-manager-crds:main"
}

import {
  to = github_repository.repos["k8s-cloudflare"]
  id = "k8s-cloudflare"
}

import {
  to = github_branch_protection.main["k8s-cloudflare"]
  id = "k8s-cloudflare:main"
}

import {
  to = github_repository.repos["k8s-coredns"]
  id = "k8s-coredns"
}

import {
  to = github_branch_protection.main["k8s-coredns"]
  id = "k8s-coredns:main"
}

import {
  to = github_repository.repos["k8s-external-secrets"]
  id = "k8s-external-secrets"
}

import {
  to = github_branch_protection.main["k8s-external-secrets"]
  id = "k8s-external-secrets:main"
}

import {
  to = github_repository.repos["k8s-external-secrets-crds"]
  id = "k8s-external-secrets-crds"
}

import {
  to = github_branch_protection.main["k8s-external-secrets-crds"]
  id = "k8s-external-secrets-crds:main"
}

import {
  to = github_repository.repos["k8s-garage"]
  id = "k8s-garage"
}

import {
  to = github_branch_protection.main["k8s-garage"]
  id = "k8s-garage:main"
}

import {
  to = github_repository.repos["k8s-github-runner"]
  id = "k8s-github-runner"
}

import {
  to = github_branch_protection.main["k8s-github-runner"]
  id = "k8s-github-runner:main"
}

import {
  to = github_repository.repos["k8s-grafana"]
  id = "k8s-grafana"
}

import {
  to = github_branch_protection.main["k8s-grafana"]
  id = "k8s-grafana:main"
}

import {
  to = github_repository.repos["k8s-graphql-router"]
  id = "k8s-graphql-router"
}

import {
  to = github_branch_protection.main["k8s-graphql-router"]
  id = "k8s-graphql-router:main"
}

import {
  to = github_repository.repos["k8s-hdmi-switch"]
  id = "k8s-hdmi-switch"
}

import {
  to = github_branch_protection.main["k8s-hdmi-switch"]
  id = "k8s-hdmi-switch:main"
}

import {
  to = github_repository.repos["k8s-health"]
  id = "k8s-health"
}

import {
  to = github_branch_protection.main["k8s-health"]
  id = "k8s-health:main"
}

import {
  to = github_repository.repos["k8s-home-assistant"]
  id = "k8s-home-assistant"
}

import {
  to = github_branch_protection.main["k8s-home-assistant"]
  id = "k8s-home-assistant:main"
}

import {
  to = github_repository.repos["k8s-homepage"]
  id = "k8s-homepage"
}

import {
  to = github_branch_protection.main["k8s-homepage"]
  id = "k8s-homepage:main"
}

import {
  to = github_repository.repos["k8s-kube-state-metrics"]
  id = "k8s-kube-state-metrics"
}

import {
  to = github_branch_protection.main["k8s-kube-state-metrics"]
  id = "k8s-kube-state-metrics:main"
}

import {
  to = github_repository.repos["k8s-lib-ci-rbac"]
  id = "k8s-lib-ci-rbac"
}

import {
  to = github_branch_protection.main["k8s-lib-ci-rbac"]
  id = "k8s-lib-ci-rbac:main"
}

import {
  to = github_repository.repos["k8s-matter-server"]
  id = "k8s-matter-server"
}

import {
  to = github_branch_protection.main["k8s-matter-server"]
  id = "k8s-matter-server:main"
}

import {
  to = github_repository.repos["k8s-node-exporter"]
  id = "k8s-node-exporter"
}

import {
  to = github_branch_protection.main["k8s-node-exporter"]
  id = "k8s-node-exporter:main"
}

import {
  to = github_repository.repos["k8s-openbao"]
  id = "k8s-openbao"
}

import {
  to = github_branch_protection.main["k8s-openbao"]
  id = "k8s-openbao:main"
}

import {
  to = github_repository.repos["k8s-pihole"]
  id = "k8s-pihole"
}

import {
  to = github_branch_protection.main["k8s-pihole"]
  id = "k8s-pihole:main"
}

import {
  to = github_repository.repos["k8s-prometheus"]
  id = "k8s-prometheus"
}

import {
  to = github_branch_protection.main["k8s-prometheus"]
  id = "k8s-prometheus:main"
}

import {
  to = github_repository.repos["k8s-speedtest-exporter"]
  id = "k8s-speedtest-exporter"
}

import {
  to = github_branch_protection.main["k8s-speedtest-exporter"]
  id = "k8s-speedtest-exporter:main"
}

import {
  to = github_repository.repos["k8s-traefik"]
  id = "k8s-traefik"
}

import {
  to = github_branch_protection.main["k8s-traefik"]
  id = "k8s-traefik:main"
}

import {
  to = github_repository.repos["k8s-zot"]
  id = "k8s-zot"
}

import {
  to = github_branch_protection.main["k8s-zot"]
  id = "k8s-zot:main"
}

import {
  to = github_repository.repos["pi-health"]
  id = "pi-health"
}

import {
  to = github_branch_protection.main["pi-health"]
  id = "pi-health:main"
}

import {
  to = github_repository.repos["pi-provision"]
  id = "pi-provision"
}

import {
  to = github_branch_protection.main["pi-provision"]
  id = "pi-provision:main"
}

import {
  to = github_repository.repos["steamos-provision"]
  id = "steamos-provision"
}

import {
  to = github_branch_protection.main["steamos-provision"]
  id = "steamos-provision:main"
}

import {
  to = github_repository.repos["ui-hdmi-switch"]
  id = "ui-hdmi-switch"
}

import {
  to = github_branch_protection.main["ui-hdmi-switch"]
  id = "ui-hdmi-switch:main"
}

