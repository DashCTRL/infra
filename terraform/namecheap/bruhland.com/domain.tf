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

resource "namecheap_record" "bruhland1" {
    domain = "bruhland.com"
    host   = "*"
    record_type = "A"
    address = "51.79.52.150"
    ttl     = "1800"
}

resource "namecheap_record" "bruhland2" {
    domain = "bruhland.com"
    host   = "@"
    record_type = "A"
    address = "51.79.52.150"
    ttl     = "1800"
}

resource "namecheap_record" "bruhland3" {
    domain = "bruhland.com"
    host   = "www"
    record_type = "A"
    address = "51.79.52.150"
    ttl     = "1800"
}

resource "namecheap_record" "bruhland4" {
    domain = "bruhland.com"
    host   = "@"
    record_type = "AAAA"
    address = "2607:5300:205:200:0:0:0:296"
    ttl     = "1800"
}

resource "namecheap_record" "bruhland5" {
    domain = "bruhland.com"
    host   = "@"
    record_type = "CAA"
    address = "0 issue \"letsencrypt.org\""
    ttl     = "1800"
}

resource "namecheap_record" "bruhland6" {
    domain = "bruhland.com"
    host   = "@"
    record_type = "TXT"
    address = "v=spf1 include:spf.efwd.registrar-servers.com ~all"
    ttl     = "1800"
}
