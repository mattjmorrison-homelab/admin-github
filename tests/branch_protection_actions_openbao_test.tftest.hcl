run "actions_openbao_is_a_member_of_repos" {
  command = plan

  assert {
    condition     = contains(local.repos, "actions-openbao")
    error_message = "local.repos must include \"actions-openbao\""
  }
}
