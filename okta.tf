# Okta config
resource "okta_group" "vault-admins" {
  name        = "vault-admins"
  description = ""
}

resource "okta_group" "vault-devs" {
  name        = "vault-devs"
  description = ""
}

resource "okta_app_oauth" "vault" {
  label       = var.okta_tile_app_label
  type        = "web"
  grant_types = ["authorization_code", "implicit", "refresh_token"]
  redirect_uris = ["${var.vault_addr}/ui/vault/auth/${var.okta_mount_path}/oidc/callback",
    # the localhost on the cli port, usually 8250, is required below if you want to use CLI-based auth, ie
    # $ vault login -method=oidc -path=okta_oidc role=okta_admin
    "http://localhost:${var.cli_port}/oidc/callback"
  ]
  response_types            = ["id_token", "code"]
  consent_method            = "REQUIRED"
  post_logout_redirect_uris = [var.vault_addr]
  login_uri                 = "${var.vault_addr}/ui"
  refresh_token_rotation    = "STATIC"
  lifecycle {
    ignore_changes = [groups]
  }
  groups_claim {
    type        = "FILTER"
    filter_type = "STARTS_WITH"
    name        = "groups"
    value       = "vault"
  }
  login_mode   = "SPEC"
  login_scopes = ["openid", "email", "profile"]
  hide_web     = false
  hide_ios     = false
}

resource "okta_app_oauth_api_scope" "vault" {
  app_id = okta_app_oauth.vault.id
  issuer = var.okta_base_url_full
  scopes = ["okta.groups.read", "okta.users.read.self"]
}

resource "okta_app_group_assignments" "vault-groups" {
  app_id = okta_app_oauth.vault.id
  group {
    id = okta_group.vault-admins.id
  }
  group {
    id = okta_group.vault-devs.id
  }
}

resource "okta_auth_server" "vault" {
  audiences   = [var.okta_auth_audience]
  description = ""
  name        = "vault"
  issuer_mode = var.okta_issue_mode
  status      = "ACTIVE"
}

resource "okta_auth_server_claim" "example" {
  auth_server_id          = okta_auth_server.vault.id
  name                    = "groups"
  value_type              = "GROUPS"
  group_filter_type       = "STARTS_WITH"
  value                   = "vault-"
  scopes                  = ["profile"]
  claim_type              = "IDENTITY"
  always_include_in_token = true
}

resource "okta_auth_server_policy" "vault" {
  auth_server_id   = okta_auth_server.vault.id
  status           = "ACTIVE"
  name             = "vault policy"
  description      = ""
  priority         = 1
  client_whitelist = ["ALL_CLIENTS"]
}

resource "okta_auth_server_policy_rule" "example" {
  auth_server_id       = okta_auth_server.vault.id
  policy_id            = okta_auth_server_policy.vault.id
  status               = "ACTIVE"
  name                 = "default"
  priority             = 1
  group_whitelist      = ["EVERYONE"]
  scope_whitelist      = ["*"]
  grant_type_whitelist = ["client_credentials", "authorization_code", "implicit"]
}

# Add user to groups
data "okta_user" "example" {
  search {
    name  = "profile.email"
    value = var.okta_user_email
  }
}

resource "okta_user_group_memberships" "example" {
  user_id = data.okta_user.example.id
  groups = [
    okta_group.vault-admins.id,
    okta_group.vault-devs.id,
  ]
}

