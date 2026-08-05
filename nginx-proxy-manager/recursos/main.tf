terraform {
  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 1.18.0"
    }
  }
}

variable "dominio" {
  type        = string
  description = "Dominio principal para la entrada (ej. app.ejemplo.com)"
}

variable "host_destino" {
  type        = string
  description = "Host de destino / Forward host (ej. 192.168.1.50)"
}

variable "puerto_destino" {
  type        = number
  description = "Puerto de destino / Forward port (ej. 8080)"
}

variable "npm_api_url" {
  type        = string
  description = "URL base de la API de Nginx Proxy Manager (ej. http://18.145.35.72/api)"
}

variable "npm_token" {
  type        = string
  description = "Token Bearer JWT para autenticar con NPM"
  sensitive   = true
}

variable "esquema_destino" {
  type        = string
  description = "Esquema de forward (http o https)"
  default     = "http"
}

variable "certificate_id" {
  type        = string
  description = "ID del certificado SSL existente, o 'new' para aprovisionar uno nuevo. Requerido si Force SSL está activo."
  default     = "new"
}

provider "restapi" {
  uri                  = var.npm_api_url
  write_returns_object = true
  
  headers = {
    "Authorization" = "Bearer ${var.npm_token}"
    "Content-Type"  = "application/json"
  }
}

resource "restapi_object" "npm_proxy_host" {
  path = "/nginx/proxy-hosts"
  
  data = jsonencode({
    # Variables de mapeo directo
    domain_names            = [var.dominio]
    forward_scheme          = var.esquema_destino
    forward_host            = var.host_destino
    forward_port            = var.puerto_destino
    
    # Opciones requeridas activadas por defecto
    block_exploits          = true
    allow_websocket_upgrade = true
    ssl_forced              = true
    hsts_enabled            = true
    http2_support           = true
    hsts_subdomains         = true
    trust_forwarded_proto   = true
    
    # Certificado requerido si ssl_forced es true
    certificate_id          = var.certificate_id
  })

  # Identificador interno del objeto que retorna la API de NPM
  id_attribute = "id"
}
