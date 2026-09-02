.PHONY: clear-repo-state

# One-time re-baseline tool (see _imports_generated.tf and README's rename
# incident notes): drops every github_repository.repos[*] and
# github_branch_protection.main[*] entry from real state so those addresses
# can be re-imported cleanly. Doesn't touch GitHub itself, only tofu's
# tracking of it. Run via the "Clear repo state" GitHub Action, which is the
# only thing with real backend network access + credentials.
clear-repo-state:
	# -d '\n' is required: default xargs treats the addresses' embedded
	# double quotes as shell-style quoting and strips them, leaving tofu
	# an invalid unquoted index (e.g. repos[k8s-node-exporter]).
	tofu state list | grep -E '^(github_repository\.repos|github_branch_protection\.main)\[' | xargs -d '\n' -n1 tofu state rm
