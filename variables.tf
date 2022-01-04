variable "vault_addr" {
  type        = string
  description = "Vault address in the form of https://domain:8200"
}

variable "vault_namespace" {
  type        = string
  description = "namespace in which to mount the auth method"
  default     = ""
}

variable "okta_org_name" {
  type        = string
  description = "The org name, ie for dev environments `dev-123456`"
}

variable "okta_base_url" {
  type        = string
  description = "The Okta SaaS endpoint, usually okta.com or oktapreview.com"
}

variable "okta_base_url_full" {
  type        = string
  description = "Full URL of Okta login, usually instanceID.okta.com, ie https://dev-208447.okta.com"
}

variable "okta_issue_mode" {
  type        = string
  description = "Indicates whether the Okta Authorization Server uses the original Okta org domain URL or a custom domain URL as the issuer of ID token for this client. ORG_URL = foo.okta.com, CUSTOM_URL = custom domain"
  default     = "ORG_URL"
}

variable "okta_api_token" {
  type        = string
  description = "Okta API key"
}

variable "okta_allowed_groups" {
  type        = list(any)
  description = "Okta group for Vault admins"
  default     = ["vault_admins"]
}

variable "okta_mount_path" {
  type        = string
  description = "Mount path for Okta auth"
  default     = "okta_oidc"
}

variable "okta_user_email" {
  type        = string
  description = "e-mail of a user to dynamically add to the groups created by this config"
}

variable "okta_tile_app_label" {
  type        = string
  description = "HCP Vault"
}

# variable "okta_client_id" {
#   type        = string
#   description = "Okta Vault app client ID"
# }

# variable "okta_client_secret" {
#   type        = string
#   description = "Okta Vault app client secret"
# }

# variable "okta_bound_audiences" {
#   type        = list(any)
#   description = "A list of allowed token audiences"
# }

variable "okta_auth_audience" {
  type        = string
  description = ""
  default     = "api://vault"
}

variable "cli_port" {
  type        = number
  description = "Port to open locally to login with the CLI"
  default     = 8250
}

variable "okta_default_lease_ttl" {
  type        = string
  description = "Default lease TTL for Vault tokens"
  default     = "12h"
}

variable "okta_max_lease_ttl" {
  type        = string
  description = "Maximum lease TTL for Vault tokens"
  default     = "768h"
}

variable "okta_token_type" {
  type        = string
  description = "Token type for Vault tokens"
  default     = "default-service"
}

variable "roles" {
  type    = map(any)
  default = {}

  description = <<EOF
Map of Vault role names to their bound groups and token policies. Structure looks like this:
```
roles = {
  okta_admin = {
    token_policies = ["admin-policy"]
    bound_groups = ["vault-admins"]
  },
  okta_devs  = {
    token_policies = ["devs-policy"]
    bound_groups = ["vault-devs"]
  }
}
```
EOF
}
