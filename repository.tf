resource "github_repository" "repos" {
  for_each = local.repos

  name       = each.value
  visibility = "public"
  auto_init  = true

  has_issues   = true
  has_projects = true
  has_wiki     = true

  # Step 2 of archiving a repo in local.archived_repos -- branch protection
  # must already be gone (step 1, see branch_protection.tf) before this
  # lands, since GitHub rejects branch-protection changes on an
  # already-archived repo.
  archived = contains(local.archived_repos, each.value)

  lifecycle {
    prevent_destroy = true
  }
}
