variable "s3_endpoint" {}
variable "cloudflare_account_id" {}

terraform {
  backend "s3" {
    bucket       = __CHANGE_ME__
    key          = __CHANGE_ME__
    region       = "auto"
    use_lockfile = true

    # from https://developers.cloudflare.com/terraform/advanced-topics/remote-backend/
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true

    endpoints = {
      s3 = var.s3_endpoint
    }
  }
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
    dnsimple = {
      source  = "dnsimple/dnsimple"
      version = "~> 1.5"
    }
  }
}

provider "dnsimple" {}
provider "cloudflare" {}

locals {
  domain = __CHANGE_ME__
}

resource "dnsimple_zone" "domain" {
  name   = local.domain
  active = true
}

resource "dnsimple_domain_delegation" "site" {
  domain       = local.domain
  name_servers = cloudflare_zone.site.name_servers
}

resource "cloudflare_zone" "site" {
  account = {
    id = var.cloudflare_account_id
  }
  name = local.domain
  type = "full"
}

resource "cloudflare_zone_setting" "https" {
  zone_id    = cloudflare_zone.site.id
  setting_id = "always_use_https"
  value      = "on"
}
