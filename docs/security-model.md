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

- Unknown hosts are rejected by dedicated default servers
- HTTP is redirected to HTTPS for known sites
- Application-safe security headers are set centrally
- Content Security Policy is configured per application rather than as one permissive global rule
- Probe and leak paths are blocked before backend routing
- Per-domain logging keeps application traffic easier to inspect
- Forwarded client addresses are accepted only from explicitly trusted proxy/CDN source networks
- The proxy is the only normal web path into the backend network

### Backend level

- No direct public exposure
- Application HTTP only from the reverse proxy
- SSH restricted to the intended management path/network
- No dependency on public CMS administration endpoints
- Operating-system updates remain possible using controlled outbound routing

### Reactive blocking

Fail2Ban is treated as an additional control, not as a replacement for network isolation or restrictive firewall rules.

The SSH jail can use a normal local firewall action because the offending host connects directly to SSH. Web jails require more care when nginx is behind a CDN/edge: after trusted real-IP processing the logs can contain the real visitor address, but the TCP connection may still originate from the edge. In that case a local firewall ban of the visitor address is ineffective and provider-side blocking or another ingress-aware action is required.

For that reason, the example nginx jails are disabled by default until the action has been selected and tested for the real ingress path.

## Validation principle

Security checks include negative tests as well as positive tests.

Examples:

```text
Proxy → backend HTTP                 expected: allowed
Client → backend directly            expected: blocked
Backend → unrelated backend HTTP     expected: blocked
Backend → package repository         expected: allowed
Internet → backend directly          expected: blocked
Unknown hostname → reverse proxy     expected: rejected
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
