run "k8s_host_rbac_is_a_member_of_repos" {
  command = plan

  assert {
    condition     = contains(local.repos, "k8s-host-rbac")
    error_message = "local.repos must include \"k8s-host-rbac\""
  }
}
