# mattjmorrison-homelab-dispatch is a service account whose sole purpose is
# holding a fine-grained PAT (scoped to `Actions: write` only) that other
# repos' CI uses to trigger graph-router's publish workflow via
# workflow_dispatch whenever a subgraph deploys. Org membership alone only
# grants read on a public repo, so the account needs this direct Write
# ("push") grant on graph-router for that PAT's Actions: write to take
# effect here.
#
# The account doesn't exist yet -- it's being created manually (GitHub has
# no API for account creation). `tofu apply` for this resource will fail
# with a GitHub API error (no such user) until it does. Don't merge this
# until the account exists.
resource "github_repository_collaborator" "graph_router_dispatch" {
  repository = github_repository.repos["graph-router"].name
  username   = "mattjmorrison-homelab-dispatch"
  permission = "push"
}
