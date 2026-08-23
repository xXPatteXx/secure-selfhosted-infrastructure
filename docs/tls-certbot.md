# TLS and Certbot

## Certificate model

Each public domain should have its own certificate covering:

- root domain, for example `example.com`
- `www` subdomain, for example `www.example.com`

TLS terminates at the reverse proxy in the documented design; backend servers do not need public certificates for the normal proxy-to-backend HTTP path.

## Renewal

Certbot can renew certificates automatically through the systemd timer:

```bash
systemctl status certbot.timer
sudo certbot renew --dry-run
```

## ACME challenge exception

For HTTP-01, the challenge path must remain reachable through the intended public request path:

```nginx
location ^~ /.well-known/acme-challenge/ {
    root /var/www/letsencrypt;
    allow all;
}
```

Do not block this path in global hardening snippets.

If the origin accepts HTTP/HTTPS only from a trusted edge/CDN, make sure HTTP-01 validation is forwarded through that edge. If that is not appropriate for the deployment, use another ACME method such as DNS-01 instead of broadly exposing the origin.
