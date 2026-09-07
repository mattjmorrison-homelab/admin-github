# Verifies homelab-woodpecker still exists as a repo (github_repository
# stays managed) but is excluded from branch protection -- step 1 of
# archiving it, see the comment in branch_protection.tf.

mock_provider "github" {}

run "homelab_woodpecker_has_no_branch_protection" {
  command = plan

  variables {
    github_owner = "mattjmorrison-homelab"
  }

  assert {
    condition     = contains(local.repos, "homelab-woodpecker")
    error_message = "local.repos must still include \"homelab-woodpecker\" -- the repository resource stays managed even once archived."
  }

  assert {
    condition     = contains(local.archived_repos, "homelab-woodpecker")
    error_message = "local.archived_repos must include \"homelab-woodpecker\"."
  }

  assert {
    condition     = !contains(local.active_repos, "homelab-woodpecker")
    error_message = "local.active_repos must not include \"homelab-woodpecker\" -- it must be excluded from github_branch_protection.main's for_each."
  }
}
