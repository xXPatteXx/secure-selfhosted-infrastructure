# Networking

## Intended traffic flow

```text
Client → Cloudflare → Reverse Proxy → Internal Backend
```

## Firewall baseline

| Service | Port | Allowed source |
|---|---:|---|
| SSH | 22/tcp | trusted internal network only |
| HTTP | 80/tcp | Cloudflare IP ranges only |
| HTTPS | 443/tcp | Cloudflare IP ranges only |
| Monitoring | 19999/tcp | trusted internal network only |

## IPv6 note

If IPv6 is not actively managed, either configure equivalent IPv6 firewall rules or disable IPv6 consistently. A half-configured IPv6 setup can create bypass paths around IPv4-only firewall assumptions.

## Validation commands

```bash
ss -tulpen
ip a
sudo ufw status numbered
curl -I https://example.com
```
