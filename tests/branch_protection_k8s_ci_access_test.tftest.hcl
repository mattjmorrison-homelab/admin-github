run "k8s_ci_access_is_a_member_of_repos" {
  command = plan

  assert {
    condition     = contains(local.repos, "k8s-ci-access")
    error_message = "local.repos must include \"k8s-ci-access\""
  }
}
