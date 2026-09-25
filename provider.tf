terraform {
  required_version = ">= 1.6.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  # State lives in this repo's own dedicated Garage bucket (Phase 1b,
  # admin-openbao#39) -- migrated off the old shared tofu-state bucket,
  # confirmed live via a zero-drift plan against the copied state. Not
  # locally, since CI runs in a fresh pod each time. Credentials come
  # from AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY (CI: fetched directly
  # from OpenBao by actions-tofu/fetch-credentials into GITHUB_ENV, no
  # Kubernetes Secret involved; locally: your own values from
  # kv/homelab/service/k8s-garage/admin-github/tofu-state-*), not from
  # this file.
  backend "s3" {
    bucket = "admin-github-tofu-state"
    key    = "admin-github/terraform.tfstate"
    region = "garage"

    endpoints = {
      s3 = "http://garage.garage.svc.cluster.local:3900"
    }

    use_path_style              = true
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
  }
}

provider "github" {
  owner = var.github_owner
}
