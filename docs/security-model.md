# Security Model

## Threat model

The setup expects regular automated scans for:

- WordPress login brute-force attempts
- XML-RPC abuse
- `.git`, `.env`, backup and config leak probes
- User enumeration attempts
- Unknown host header requests

## Controls

### Network level

- Default deny inbound firewall policy
- HTTP/HTTPS only from Cloudflare IP ranges
- SSH only from trusted internal networks
- Monitoring only from trusted internal networks

### Reverse proxy level

- Unknown hosts return `444`
- Security headers are set centrally
- Probe paths are blocked before backend routing
- WordPress admin paths can be restricted to internal networks
- Direct access to sensitive bootstrap files can be denied

### Reactive blocking

Fail2Ban watches nginx and SSH logs and applies bans for repeated suspicious behavior.

## Sensitive data policy

Do not publish:

- Real internal IP addresses
- Real domain mapping tables
- Cloudflare API tokens
- SSH usernames or keys
- Complete production firewall rules without sanitization
- Full logs containing client IPs
