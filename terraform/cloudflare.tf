locals {
  # Strip the https:// prefix and trailing slash from the Cloud Run URL for use as a CNAME target
  cloud_run_hostname = replace(replace(google_cloud_run_v2_service.app.uri, "https://", ""), "/", "")

  # Build the WAF expression: allow Wiz ASM IPs + home IP, block everything else
  wiz_ip_list = length(var.wiz_asm_ips) > 0 ? join(" ", [for ip in var.wiz_asm_ips : "ip.src eq ${ip}"]) : null
  waf_allow_expression = local.wiz_ip_list != null ? "(${local.wiz_ip_list} or ip.src eq ${var.home_ip})" : "ip.src eq ${var.home_ip}"
  waf_block_expression = "(http.host eq \"${var.hostname}\") and not (${local.waf_allow_expression})"
}

# Proxied DNS record — hides the real Cloud Run URL behind Cloudflare edge
resource "cloudflare_dns_record" "app" {
  zone_id = var.cf_zone_id
  name    = "ai-dlc"
  type    = "CNAME"
  content = local.cloud_run_hostname
  proxied = true
  ttl     = 1
}

# WAF custom rule — block all traffic except Wiz ASM scanners + your home IP
resource "cloudflare_ruleset" "waf" {
  zone_id = var.cf_zone_id
  name    = "AI DLC demo WAF"
  kind    = "zone"
  phase   = "http_request_firewall_custom"

  rules = [{
    description = "Allow only Wiz ASM scanners and home IP to reach the demo app"
    expression  = local.waf_block_expression
    action      = "block"
    enabled     = true
  }]
}

# Origin rule — keep external traffic on 443 while routing to Cloud Run HTTPS origin
resource "cloudflare_ruleset" "origin" {
  zone_id = var.cf_zone_id
  name    = "AI DLC demo origin rules"
  kind    = "zone"
  phase   = "http_request_origin"

  rules = [{
    expression = "(http.host eq \"${var.hostname}\")"
    action     = "route"
    action_parameters = {
      origin = {
        host = local.cloud_run_hostname
        port = 443
      }
    }
    enabled = true
  }]
}
