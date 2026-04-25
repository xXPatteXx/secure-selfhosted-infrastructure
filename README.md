# Secure Self-Hosted Infrastructure

A sanitized showcase repository for a hardened self-hosted WordPress infrastructure using a central reverse proxy, Cloudflare, nginx, UFW, Fail2Ban, Let's Encrypt and internal monitoring.

> This repository is intentionally generic. It documents concepts, patterns and example configurations without exposing real domains, IP addresses or credentials.

## Goals

- Single public entry point through a reverse proxy
- Backend servers isolated in a private network
- Web access restricted to Cloudflare origin traffic
- WordPress admin paths protected before requests reach the backend
- Automated TLS certificates via Let's Encrypt / Certbot
- Centralized logging, monitoring and active blocking

## Architecture

```text
Client
  ↓ HTTPS
Cloudflare
  ↓ HTTP/HTTPS origin traffic
Reverse Proxy (nginx)
  ↓ internal HTTP
Backend Web Servers
```

## Security principles

- No direct public backend exposure
- HTTP/HTTPS origin access only from Cloudflare IP ranges
- SSH and monitoring only from trusted internal networks
- Unknown hosts are dropped by nginx catch-all vHosts
- Common probe paths are blocked before backend routing
- Fail2Ban escalates repeated attacks into firewall blocks

## Repository layout

```text
.
├── docs/
│   ├── architecture.md
│   ├── security-model.md
│   ├── networking.md
│   ├── tls-certbot.md
│   └── monitoring-logging.md
├── nginx/
│   ├── reverse-proxy-example.conf
│   └── snippets/
│       ├── block-probes.conf
│       └── security-headers.conf
├── fail2ban/
│   ├── jail.local.example
│   └── filter.d/
│       ├── nginx-badscan.conf
│       └── wordpress-xmlrpc.conf
└── scripts/
    ├── check-nginx.sh
    ├── check-certbot.sh
    └── analyze-nginx-logs.sh
```

## What this is not

This is not a drop-in production configuration. Adapt network ranges, domain names, Cloudflare IP lists, TLS paths and service names to your own infrastructure.

## Good next steps

1. Replace placeholders such as `example.com`, `10.0.0.0/24` and `backend.example.internal`.
2. Validate nginx config with `nginx -t` before reload.
3. Test Cloudflare origin restrictions before exposing services.
4. Run `certbot renew --dry-run` after certificate setup.
5. Verify logs and Fail2Ban jails with real traffic.
