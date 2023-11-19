##
# Cloudflare rules
##
resource "cloudflare_ruleset" "b2_request_url_rewrites" {
  zone_id = data.cloudflare_zone.dns.id
  name    = "Backblaze B2 URL Rewrite"
  kind    = "zone"
  phase   = "http_request_transform"

  rules {
    action = "rewrite"
    action_parameters {
      uri {
        path {
          expression = "concat(\"/file/${local.b2_public_bucket}\",http.request.uri.path)"
        }
      }
    }
    description = "B2 - Add /file/${local.b2_public_bucket} to URL"
    expression  = "(http.host eq \"${local.b2_domain}\" and not starts_with(http.request.uri.path, \"/file/${local.b2_public_bucket}\"))"
    enabled     = true
  }
}

resource "cloudflare_ruleset" "b2_response_header_rewrites" {
  zone_id = data.cloudflare_zone.dns.id
  name    = "Backblaze HTTP Response Headers"
  kind    = "zone"
  phase   = "http_response_headers_transform"

  rules {
    action = "rewrite"

    # !! THESE HEADERS MUST BE IN ALPHABETICAL ORDER !!
    action_parameters {
      headers {
        name      = "Access-Control-Allow-Origin"
        operation = "set"
        value     = "*"
      }
      headers {
        name       = "ETag"
        operation  = "set"
        expression = "concat(http.response.headers[\"x-bz-content-sha1\"][0],http.response.headers[\"x-bz-upload-timestamp\"][0],http.response.headers[\"x-bz-file-id\"][0])"
      }
      headers {
        name      = "x-bz-content-sha1"
        operation = "remove"
      }
      headers {
        name      = "x-bz-file-id"
        operation = "remove"
      }
      headers {
        name      = "x-bz-file-name"
        operation = "remove"
      }
      headers {
        name      = "x-bz-info-src_last_modified_millis"
        operation = "remove"
      }
      headers {
        name      = "x-bz-upload-timestamp"
        operation = "remove"
      }
    }
    description = "B2 - Remove x-bz-*, add ETag, and set CORS"
    expression  = "(http.host eq \"${local.b2_domain}\")"
    enabled     = true
  }
}
