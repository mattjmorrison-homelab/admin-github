#!/usr/bin/env bash
set -euo pipefail

# One-time state repair, run once via the manually-triggered
# `fix-repo-rename-state` workflow. Re-keys Terraform state from old repo
# names to new names (state-only, no GitHub API calls) so that a follow-up
# PR updating `local.repos` to the new names produces a clean in-place
# rename, not destroy+create cycles.
#
# CRITICAL: The follow-up PR updating `local.repos` to new names must
# merge IMMEDIATELY after this script runs, with NO other admin-github PR
# merged in between. During the window after state re-keying but before
# local.repos is updated, state and config are keyed differently. Any
# tofu apply in that gap will either hard-fail on github_repository.repos
# (prevent_destroy guard) or silently destroy+recreate
# github_branch_protection.main. Merge the follow-up PR immediately.
#
# Not meant to be re-run once state matches local.repos again.

declare -A renames=(
  [homelab-argocd]=k8s-argocd
  [homelab-apps]=k8s-apps
  [homelab-homepage]=k8s-homepage
  [k8s-ci-rbac]=k8s-lib-ci-rbac
  [homelab-alertmanager]=k8s-alertmanager
  [homelab-prometheus]=k8s-prometheus
  [homelab-zot]=k8s-zot
  [homelab-cert-manager]=k8s-cert-manager
  [homelab-cert-manager-config]=k8s-cert-manager-config
  [homelab-cert-manager-crds]=k8s-cert-manager-crds
  [homelab-cloudflare]=k8s-cloudflare
  [homelab-coredns]=k8s-coredns
  [homelab-external-secrets]=k8s-external-secrets
  [homelab-external-secrets-crds]=k8s-external-secrets-crds
  [homelab-grafana]=k8s-grafana
  [homelab-home-assistant]=k8s-home-assistant
  [homelab-kube-state-metrics]=k8s-kube-state-metrics
  [homelab-node-exporter]=k8s-node-exporter
  [homelab-pihole]=k8s-pihole
  [homelab-speedtest-exporter]=k8s-speedtest-exporter
  [homelab-traefik]=k8s-traefik
  [homelab-argocd-image-updater]=k8s-argocd-image-updater
)

for old in "${!renames[@]}"; do
  new="${renames[$old]}"
  echo "== $old -> $new =="
  tofu state mv "github_repository.repos[\"$old\"]" "github_repository.repos[\"$new\"]"
  tofu state mv "github_branch_protection.main[\"$old\"]" "github_branch_protection.main[\"$new\"]"
done

echo "Done — ${#renames[@]} repos re-keyed. Next: open a PR updating local.repos to the new names."
