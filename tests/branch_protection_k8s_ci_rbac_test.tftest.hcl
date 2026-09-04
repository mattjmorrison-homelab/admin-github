run "k8s_ci_rbac_is_a_member_of_repos" {
  command = plan

  assert {
    condition     = contains(local.repos, "k8s-ci-rbac")
    error_message = "local.repos must include \"k8s-ci-rbac\""
  }
}
