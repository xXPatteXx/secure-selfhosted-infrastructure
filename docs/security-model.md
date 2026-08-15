# Security Model

## Threat model

The environment assumes regular automated scanning and opportunistic attacks against public web infrastructure, including:

- `.git`, `.env`, backup and configuration leak probes
- Requests for common CMS and framework paths that are not in use
- Unknown or manipulated host headers
- Repeated authentication attempts
- Generic exploit and reconnaissance requests

The design also considers lateral movement inside the local environment. A compromised client or backend should not automatically gain unrestricted access to the remaining server network.

## Controls

### Network level

- Default-deny inbound firewall policy
- Backend systems placed in a dedicated network segment
- Backend HTTP allowed only from the reverse proxy
- Client-to-backend traffic isolated
- Administrative access provided through explicit management paths
- Outbound maintenance traffic allowed without adding inbound exposure

### Reverse proxy level

- Unknown hosts return `444`
- HTTP is redirected to HTTPS
- Security headers are set centrally
- Probe and leak paths are blocked before backend routing
- Per-domain logging keeps application traffic easier to inspect
- The proxy is the only normal web path into the backend network

### Backend level

- No direct public exposure
- Application HTTP only from the reverse proxy
- SSH restricted to the intended management path/network
- No dependency on public CMS administration endpoints
- Operating-system updates remain possible using controlled outbound routing

### Reactive blocking

Fail2Ban watches nginx and SSH logs and can apply progressively longer bans to repeated offenders.

Reactive blocking is treated as an additional control, not as a replacement for network isolation or restrictive firewall rules.

## Validation principle

Security checks include negative tests as well as positive tests.

Examples:

```text
Proxy → backend HTTP                 expected: allowed
Client → backend directly            expected: blocked
Backend → unrelated backend HTTP     expected: blocked
Backend → package repository         expected: allowed
Internet → backend directly          expected: blocked
```

A change is not considered complete until both required connectivity and intended isolation have been checked.

## Sensitive data policy

Do not publish:

- Real internal addressing plans unless intentionally disclosed
- Real domain-to-backend mapping tables
- API tokens or credentials
- SSH private keys
- Secrets embedded in Fail2Ban actions or scripts
- Raw production logs containing client data
- Exact management endpoints where disclosure provides no documentation value

Repository examples should preserve the architecture while sanitizing operational details.
