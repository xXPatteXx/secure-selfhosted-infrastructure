# TLS and Certbot

## Certificate model

Each public domain should have its own certificate covering:

- root domain, for example `example.com`
- `www` subdomain, for example `www.example.com`

## Renewal

Certbot can renew certificates automatically through the systemd timer:

```bash
systemctl status certbot.timer
sudo certbot renew --dry-run
```

## ACME challenge exception

The ACME HTTP-01 challenge path must remain reachable:

```nginx
location ^~ /.well-known/acme-challenge/ {
    root /var/www/letsencrypt;
    allow all;
}
```

Do not block this path in global hardening snippets.
