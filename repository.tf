resource "github_repository" "repos" {
  for_each = local.repos

  name       = each.value
  visibility = "public"
  auto_init  = true

  has_issues   = true
  has_projects = true
  has_wiki     = true

  lifecycle {
    prevent_destroy = true
  }
}
