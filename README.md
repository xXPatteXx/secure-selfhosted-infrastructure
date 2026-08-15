# Secure Self-Hosted Infrastructure

This repository documents a hardened self-hosted web infrastructure built around a central nginx reverse proxy, isolated backend servers and layered access controls.

The configuration is intentionally sanitized. It reflects a real environment and its evolution, while keeping domains, addresses, credentials and other operational details generic.

## Current design

```text
Internet
  ↓
Trusted Edge / CDN
  ↓
Gateway / Firewall
  ↓
Reverse Proxy (nginx)
  ↓
Isolated Backend Network
  ├── Web Backend A
  ├── Web Backend B
  └── Web Backend C
```

The reverse proxy is the only system allowed to reach the backend web services directly. Administrative access follows explicitly defined management paths instead of unrestricted routing between client and server networks.

Backend systems can establish controlled outbound connections for operating-system updates, DNS and certificate-related operations without becoming reachable from the public internet.

## What this project focuses on

- Single public web entry point via nginx
- Backend systems separated from client and public networks
- Default-deny inbound firewall policies
- Backend HTTP reachable only from the reverse proxy
- Explicit administrative access paths
- Controlled outbound connectivity for maintenance and updates
- TLS termination and certificate management via Let's Encrypt / Certbot
- Central security headers and request filtering
- Domain-specific logging
- Fail2Ban for repeated malicious activity
- Validation of the complete request path after infrastructure changes

## Architecture evolution

The project started as a conventional reverse-proxy setup with backends on a shared internal network. It has since moved toward stronger segmentation:

1. Backend systems were moved into a dedicated internal network.
2. Direct backend exposure was removed and firewall rules were narrowed to the reverse proxy.
3. Administrative access was separated from normal client-to-server routing.
4. Network isolation was introduced between client and backend networks.
5. Backend outbound routing and DNS were added specifically for maintenance tasks such as `apt update` and `apt upgrade`.
6. The resulting design was verified from the backend, proxy and public edge perspectives.

This is an incremental hardening process rather than a claim of a perfectly isolated or final architecture. Some transitional components may remain until the network is moved to dedicated VLANs and gateway-managed routing.

## Security model

### Network level

- Default deny for inbound connections
- Public web traffic terminates at the reverse proxy
- Backend web ports accept traffic only from the proxy
- Client and backend networks are isolated
- Management access uses explicitly defined paths
- Outbound backend access is allowed where required for maintenance

### Reverse proxy level

- Unknown hosts are dropped with catch-all virtual hosts
- HTTP is redirected to HTTPS
- Security headers are applied centrally
- Common probe and leak paths are blocked before backend routing
- Per-domain access and error logs are maintained

### Backend level

- Application servers are not publicly exposed
- Backends serve only the application content required by the proxy
- Administrative interfaces are not published to the internet
- Operating-system updates remain possible through controlled outbound routing

### Reactive controls

- Fail2Ban monitors nginx and SSH activity
- Repeated suspicious requests can be blocked automatically
- Ban durations can be increased for repeat offenders

## Validation approach

Changes are considered complete only after the relevant layers have been tested.

Typical checks include:

```bash
# Backend network state
ip route
resolvectl status
sudo ufw status verbose

# Reverse proxy
sudo nginx -t
sudo systemctl --failed
sudo fail2ban-client ping

# Proxy to backend
curl -I -H "Host: example.com" http://backend.example.internal

# Public path
curl -I https://example.com
```

Expected behavior:

```text
Public client → edge → reverse proxy → backend     allowed
Reverse proxy → backend HTTP                       allowed
Client network → backend directly                  blocked
Backend → another backend HTTP                     blocked
Backend → internet for updates/DNS                 allowed
Internet → backend directly                        blocked
```

## Repository structure

```text
.
├── docs/        Architecture, networking and security notes
├── nginx/       Reverse proxy and shared security snippets
├── fail2ban/    Example jails and filters
└── scripts/     Operational helper scripts
```

## Documentation

- [Architecture](docs/architecture.md)
- [Networking](docs/networking.md)
- [Security model](docs/security-model.md)
- [Monitoring and logging](docs/monitoring-logging.md)
- [TLS and Certbot](docs/tls-certbot.md)

## Usage

This repository is a reference and starting point, not a drop-in production configuration.

Before applying any example:

1. Replace placeholder domains, addresses and networks.
2. Adapt firewall rules to the real trust boundaries.
3. Confirm that management access remains available before applying network changes.
4. Validate nginx with `nginx -t`.
5. Test certificate renewal with `certbot renew --dry-run`.
6. Verify both allowed and intentionally blocked traffic paths.

## Current direction

The present design uses a dedicated backend segment and explicit management paths. The next logical step is moving the transitional routing components to native VLANs and gateway-managed firewall rules while keeping the same security boundaries.

The goal is not maximum complexity. The goal is a small, understandable infrastructure where every allowed path has a reason to exist.

## License

MIT
