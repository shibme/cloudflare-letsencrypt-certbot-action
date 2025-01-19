## 🛡️🔐🪪 Cloudflare DNS LetsEncrypt Certificate Generator

GitHub action for generating LetsEncrypt certificate with DNS challenge for domains parked in Cloudflare

### Input

* `cloudflare_api_token` - Cloudflare API token with Zone:DNS:Edit permission
* `domain_names` - The fully qualified domain names for which certificate is required (comma separated)
* `email` - Email address (to notify on certificate expiry)
* `certs_file_name` - The name of file in which the generated keys and certificates will be stored (default name - cert.zip)
* `dry_run` - [true/false] Will only simulate the process using DNS challenge. Will not issue an actual certificate (default - false)

### Usage

```yaml
name: Generate LetsEncrypt Certificate
on: [push]
jobs:

  build:
    name: build
    runs-on: ubuntu-latest
    steps:
    - name: Generate LetsEncrypt Cert
      uses: shibme/cloudflare-letsencrypt-certbot-generate@main
      with:
        cloudflare_dns_api_token: ${{ secrets.CLOUDFLARE_DNS_API_TOKEN }}
        domain_name: ${{ secrets.DOMAIN_NAME }}
        email: ${{ secrets.EMAIL }}
        certs_file_name: my_cert
```
The generated keys and certificates will be available in `my_cert.zip` file to be consumed by consecutive steps.