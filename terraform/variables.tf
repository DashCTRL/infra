variable "pm_api_url" {
    description = "Proxmox API URL"
    type        = string
}

variable "pm_user" {
    description = "Proxmox API user"
    type        = string
}

variable "pm_password" {
    description = "Proxmox API password"
    type        = string
}

variable "pm_tls_insecure" {
    description = "Allow insecure TLS connections to the Proxmox API"
    type        = bool
}

variable "domain" {
    description = "Domain name"
    type        = string
}