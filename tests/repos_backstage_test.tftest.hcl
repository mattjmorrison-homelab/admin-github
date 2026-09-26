run "app_backstage_is_a_member_of_repos" {
  command = plan

  assert {
    condition     = contains(local.repos, "app-backstage")
    error_message = "local.repos must include \"app-backstage\""
  }
}

run "k8s_backstage_is_a_member_of_repos" {
  command = plan

  assert {
    condition     = contains(local.repos, "k8s-backstage")
    error_message = "local.repos must include \"k8s-backstage\""
  }
}
