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

# homelab-openbao was this repo's old name before it was renamed to
# k8s-openbao -- GitHub just redirects the old name, it's the same real
# repo. Removing it from local.repos correctly drops the old state key,
# but github_repository's destroy is a real delete-repo API call, and
# prevent_destroy rightly blocks that. `removed` (declarative counterpart
# to `import`) tells Terraform to just forget this key instead, without
# touching the real repo k8s-openbao's own entry already owns.
removed {
  from = github_repository.repos["homelab-openbao"]

  lifecycle {
    destroy = false
  }
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
