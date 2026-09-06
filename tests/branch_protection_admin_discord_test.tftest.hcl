run "admin_discord_is_a_member_of_repos" {
  command = plan

  assert {
    condition     = contains(local.repos, "admin-discord")
    error_message = "local.repos must include \"admin-discord\""
  }
}
