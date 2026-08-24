# admin-openbao already exists on GitHub (predates this repo's Terraform
# ever running), so it needs importing rather than created fresh -- without
# this, the first apply would try to create a repo with a name that's
# already taken and fail with a 422. Safe to leave in place permanently:
# once the resource is in state, this becomes a no-op on later runs.
import {
  to = github_repository.repos["admin-openbao"]
  id = "admin-openbao"
}

# Same situation as admin-openbao above -- this repo (admin-github
# itself) also already exists on GitHub, predating its own Terraform
# ever applying.
import {
  to = github_repository.repos["admin-github"]
  id = "admin-github"
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
