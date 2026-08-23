# Architecture

## Overview

The setup uses a central nginx reverse proxy as the only public web entry point. Backend systems run in a dedicated internal network and are not directly exposed to the internet or normal client networks.

```text
Internet
  ↓
Trusted Edge / CDN
  ↓
Gateway / Firewall
  ↓
Reverse Proxy
  ↓
Dedicated Backend Network
  ├── Backend A
  ├── Backend B
  └── Backend C
```

The design has evolved from a shared internal network toward explicit segmentation. The reverse proxy remains the central control point, while backend access is narrowed to the minimum required paths.

## Components

### Reverse Proxy

Responsibilities:

- Accept HTTP/HTTPS requests
- Reject unknown hostnames with catch-all default servers
- Terminate TLS for known sites
- Apply application-safe shared security headers and probe blocking
- Route valid requests to internal backends
- Maintain per-domain access and error logs
- Restore original client information only from explicitly trusted edge networks

The repository separates three concerns:

- `nginx/default-deny.conf` handles unknown hostnames
- `nginx/http-context-example.conf` defines the shared log format and trusted real-IP example
- `nginx/reverse-proxy-example.conf` contains the application vHost

### Backend Servers

Responsibilities:

- Serve application content
- Accept HTTP only from the reverse proxy
- Remain unreachable from the public internet
- Use controlled outbound connectivity for DNS and operating-system maintenance

### Gateway / Firewall

Responsibilities:

- Separate client, management and backend traffic
- Enforce network isolation where available
- Expose only explicitly required public services
- Provide controlled routing toward the internet

### Trusted Edge

Responsibilities:

- Public DNS and edge proxying where used
- Optional WAF and rate limiting
- Hide the origin from normal public access paths
- Forward client information using a documented header

Forwarded client-IP headers are not trusted on their own. nginx must accept them only when the TCP peer belongs to an explicitly configured trusted edge network.

## Management access

Administrative access is intentionally separated from normal routed client traffic. Instead of allowing broad client-to-backend access, the design uses explicit management paths to selected systems.

This keeps the client network and backend network isolated while still allowing maintenance.

## Design principles

- Single public web entry point
- Dedicated backend segment
- Default-deny inbound policy
- Backend HTTP only from the proxy
- Explicit management paths
- Controlled outbound maintenance traffic
- Centralized proxy controls without pretending every policy is application-independent
- Separate logs per project/domain
- Incremental hardening without unnecessary complexity

## Current transition

The present implementation still contains transitional routing components between the client-facing network and the backend segment. These are expected to be replaced by native VLANs and gateway-managed firewall rules later.

The intended security boundaries already match that future layout, so the migration should mainly simplify routing rather than change the application architecture.
