terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.10.0"
    }
    fastly = {
      source  = "fastly/fastly"
      version = "1.1.4"
    }
  }
  required_version = "1.1.9"
}

locals {
  domains = [
    "foo.example.com",
    "bar.example.com",
  ]
  aws_route53_zone_id = "your_route53_zone_id"
}

# fastly サービスの定義
resource "fastly_service_vcl" "example" {
  name = "hashistack-demo"

  dynamic "domain" {
    for_each = local.domains
    content {
      name = domain.value
    }
  }

  backend {
    address = "127.0.0.1"
    name    = "localhost"
  }

  force_destroy = true
}

# fastly TLS 証明書の定義 (Let's Encrypt)
resource "fastly_tls_subscription" "example" {
  depends_on            = [fastly_service_vcl.example]
  domains               = [for domain in fastly_service_vcl.example.domain : domain.name]
  certificate_authority = "lets-encrypt"
}

# 上記の "fastly_tls_subscription" リソースによって作られた証明書情報を元に、
# Route53 で管理しているドメインに、ドメイン所有権の確認に必要な CNAME レコードを自動的に追加する。
resource "aws_route53_record" "domain_validation" {
  depends_on = [fastly_tls_subscription.example]

  for_each = {
    for domain in fastly_tls_subscription.example.domains :
    replace(domain, "*.", "") => element([
      for obj in fastly_tls_subscription.example.managed_dns_challenges :
      obj if obj.record_name == "_acme-challenge.${replace(domain, "*.", "")}"
    ], 0)...
  }

  name            = each.value[0].record_name
  type            = each.value[0].record_type
  zone_id         = local.aws_route53_zone_id
  allow_overwrite = true
  records         = [each.value[0].record_value]
  ttl             = 60
}

resource "fastly_tls_subscription_validation" "example" {
  subscription_id = fastly_tls_subscription.example.id
  depends_on      = [aws_route53_record.domain_validation]
}
