run "actions_k8s_is_a_member_of_repos" {
  command = plan

  assert {
    condition     = contains(local.repos, "actions-k8s")
    error_message = "local.repos must include \"actions-k8s\""
  }
}
