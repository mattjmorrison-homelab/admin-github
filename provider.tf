terraform {
  required_version = ">= 1.6.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  # State lives in k8s-garage's tofu-state bucket, not locally — CI runs in
  # a fresh pod each time, so local state would start blank on every run.
  # Credentials come from AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY (CI: the
  # native Kubernetes secret gh-org-github-token; locally: your own values
  # from kv/homelab/gh-org), not from this file.
  backend "s3" {
    bucket = "tofu-state"
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
