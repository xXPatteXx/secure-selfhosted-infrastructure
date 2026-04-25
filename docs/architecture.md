# Architecture

## Overview

This setup uses a central reverse proxy as the only public web entry point. Backend systems run in an internal network and are not directly exposed to the internet.

```text
Internet
  ↓
Cloudflare
  ↓
nginx Reverse Proxy
  ↓
Internal Backend Servers
```

## Components

### Reverse Proxy

Responsibilities:

- Accept HTTP/HTTPS requests
- Terminate TLS
- Apply security headers and probe blocking
- Route valid requests to internal backends
- Write centralized access and error logs

### Backend Servers

Responsibilities:

- Serve application content, for example WordPress
- Stay reachable only from the internal network
- Avoid direct public exposure

### Cloudflare

Responsibilities:

- Public DNS and edge protection
- Optional WAF/rate-limiting features
- Only allowed external source for origin HTTP/HTTPS traffic

## Design principles

- Single entry point
- Backend isolation
- Centralized security on the proxy
- Separate logs per project/domain
- Scalable multi-domain routing
