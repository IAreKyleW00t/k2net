##
# BackBlaze B2 Buckets
##
resource "b2_bucket" "backups" {
  bucket_name = "k2net-backups"
  bucket_type = "allPrivate"

  default_server_side_encryption {
    mode      = "SSE-B2"
    algorithm = "AES256"
  }

  lifecycle_rules {
    file_name_prefix              = ""
    days_from_hiding_to_deleting  = 1
    days_from_uploading_to_hiding = null
  }
}
