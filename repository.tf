# Every repo in local.repos already exists on GitHub before it's ever
# added here -- the workflow is always: create the repo, then wire it
# into this file, never the other way around. So importing all of them
# by name is always correct, not just for the ones added so far.
# Already-imported repos are a no-op on every later apply once they're in
# state -- safe to leave in permanently, and this means uncommenting a
# repo in local.repos gets it imported automatically, no separate import
# block to remember.
import {
  for_each = local.repos
  to       = github_repository.repos[each.value]
  id       = each.value
}

resource "github_repository" "repos" {
  for_each = local.repos

  name       = each.value
  visibility = "public"

  has_issues   = true
  has_projects = true
  has_wiki     = true

  lifecycle {
    prevent_destroy = true
  }
}
