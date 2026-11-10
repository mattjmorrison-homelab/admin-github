run "graph_ad_reporter_is_a_member_of_repos" {
  command = plan

  assert {
    condition     = contains(local.repos, "graph-ad-reporter")
    error_message = "local.repos must include \"graph-ad-reporter\""
  }
}

run "ui_ad_reporter_is_a_member_of_repos" {
  command = plan

  assert {
    condition     = contains(local.repos, "ui-ad-reporter")
    error_message = "local.repos must include \"ui-ad-reporter\""
  }
}

run "k8s_ad_reporter_is_a_member_of_repos" {
  command = plan

  assert {
    condition     = contains(local.repos, "k8s-ad-reporter")
    error_message = "local.repos must include \"k8s-ad-reporter\""
  }
}
