terraform {
    required_providers {
        namecheap = {
        source = "namecheap/namecheap"
        version = "2.1.0"
        }
    }
}


provider "namecheap" {
    api_user   = "your_api_user"
    api_key    = "your_api_key"
    username   = "your_username"
    use_sandbox = false
}

resource "namecheap_record" "ip" {
    domain = "antoineboucher.info"
    host   = "*"
    record_type = "A"
    address = "192.99.168.233"
    ttl     = "1800"
}

resource "namecheap_record" "ip2" {
    domain = "antoineboucher.info"
    host   = "@"
    record_type = "A"
    address = "192.99.168.233"
    ttl     = "1800"
}

resource "namecheap_record" "www" {
    domain = "antoineboucher.info"
    host   = "www"
    record_type = "A"
    address = "192.99.168.233"
    ttl     = "1800"
}

resource "namecheap_record" "ipv6" {
    domain = "antoineboucher.info"
    host   = "@"
    record_type = "AAAA"
    address = "2607:5300:201:3100::545d"
    ttl     = "1800"
}

resource "namecheap_record" "letsencrypt" {
    domain = "antoineboucher.info"
    host   = "@"
    record_type = "CAA"
    address = "0 issue \"letsencrypt.org\""
    ttl     = "1800"
}

resource "namecheap_record" "ovh" {
    domain = "antoineboucher.info"
    host   = "@"
    record_type = "TXT"
    address = "v=spf1 include:spf.efwd.registrar-servers.com ~all"
    ttl     = "1800"
}
