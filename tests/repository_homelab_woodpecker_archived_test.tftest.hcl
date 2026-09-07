# Step 2 of archiving homelab-woodpecker -- see branch_protection.tf and
# the comment on this resource in repository.tf. Branch protection was
# already confirmed removed on GitHub before this landed.

mock_provider "github" {}

run "homelab_woodpecker_is_archived_everything_else_is_not" {
  command = plan

  variables {
    github_owner = "mattjmorrison-homelab"
  }

  assert {
    condition     = github_repository.repos["homelab-woodpecker"].archived == true
    error_message = "homelab-woodpecker must be archived"
  }

  assert {
    condition = alltrue([
      for name in local.active_repos : github_repository.repos[name].archived == false
    ])
    error_message = "no repo in local.active_repos should be archived"
  }
}
