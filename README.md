# Secure Self-Hosted Infrastructure

This repository documents a hardened self-hosted web infrastructure based on a reverse proxy architecture with centralized security controls.

The configuration is intentionally sanitized and designed as a reference implementation. It demonstrates patterns, concepts and example configurations without exposing real domains, IP addresses or credentials.

---

## Problem Statement

Many self-hosted environments are compromised due to avoidable issues such as:

* Publicly exposed administrative interfaces
* Missing network isolation
* Insufficient firewall restrictions
* Lack of monitoring and reactive controls

These issues are typically the result of architectural decisions rather than complex exploits.

---

## Approach

This project provides a practical baseline for a secure setup with the following characteristics:

* Single public entry point via reverse proxy
* Backend systems isolated in an internal network
* HTTP/HTTPS access restricted to trusted edge sources (e.g. Cloudflare)
* Early request filtering at proxy level
* Automated TLS certificate management via Let's Encrypt / Certbot
* Centralized logging and monitoring
* Automated blocking of malicious activity via Fail2Ban

---

## Architecture

```
Client
  ↓ HTTPS
Trusted Edge (e.g. Cloudflare)
  ↓ HTTP/HTTPS
Reverse Proxy (nginx)
  ↓ Internal Network
Backend Web Servers
```

---

## Security Model

The system is designed using a layered approach.

### Network Level

* Default deny inbound policy
* HTTP/HTTPS access limited to trusted edge IP ranges
* SSH and monitoring restricted to internal networks
* Backend systems are not directly exposed

### Reverse Proxy Level

* Unknown hosts are dropped using catch-all configurations
* Common probe and exploit paths are blocked before backend routing
* Security headers are applied centrally
* Administrative endpoints are restricted

### Application Level

* No public administrative access
* XML-RPC and enumeration endpoints are disabled or filtered
* Application servers operate behind the proxy boundary

### Reactive Controls

* Fail2Ban monitors logs and applies bans on repeated suspicious activity
* Escalation mechanisms increase ban duration for repeat offenders

---

## Monitoring and Logging

The setup includes a minimal but practical monitoring baseline:

* System metrics (CPU, memory, disk, network)
* nginx request and status metrics
* Fail2Ban status and activity
* Structured access and error logs

Monitoring is intended to remain internal or use outbound connections only.

---

## Repository Structure

```
.
├── docs/        Documentation of architecture and concepts
├── nginx/       Reverse proxy and security configuration
├── fail2ban/    Jails and filters
├── scripts/     Operational helper scripts
```

---

## Usage

This repository is intended as a reference and starting point.

Before applying any configuration:

1. Replace placeholders such as domain names and network ranges
2. Adjust firewall rules and trusted source definitions
3. Validate nginx configuration before deployment
4. Verify certificate handling with a dry run
5. Test monitoring and blocking behavior under real conditions

---

## Production Readiness Checklist

Before using this setup in a production environment, verify the following points.

### Configuration

* All placeholder values have been replaced
* Firewall rules are adapted to the actual environment
* Trusted edge IP ranges are up to date

### Network and Access Control

* Direct access to the origin server is not possible from the public internet
* HTTP/HTTPS access is restricted to trusted edge sources
* SSH access is limited to trusted internal networks
* Monitoring endpoints are not publicly exposed

### Reverse Proxy

* nginx configuration is valid:

  ```
  nginx -t
  ```
* Unknown hosts are correctly dropped
* Security headers are applied as expected
* Probe and exploit paths are blocked before backend routing

### TLS and Certificates

* Certificates are issued for all active domains
* Automatic renewal is configured and active
* Renewal test succeeds:

  ```
  certbot renew --dry-run
  ```

### Application Exposure

* Administrative interfaces are not publicly accessible
* XML-RPC and unnecessary endpoints are disabled or filtered
* Backend services are only reachable through the reverse proxy

### Monitoring and Logging

* Access and error logs are written and accessible
* Log format provides sufficient detail for analysis
* Monitoring is internal-only or outbound-based
* No sensitive log data is exposed externally

### Reactive Protection

* Fail2Ban is active and monitoring relevant logs
* Jails are correctly configured and enabled
* Suspicious activity results in bans
* Repeat offenders are escalated

### Validation Under Real Conditions

* Requests follow the intended path:

  ```
  Client → Trusted Edge → Reverse Proxy → Backend
  ```
* Direct origin access attempts are blocked
* Common attack patterns are visible in logs
* Automated blocking is triggered as expected

---

## Important Notes

* This is not a drop-in production configuration
* All values must be adapted to the target environment
* Sensitive operational data must never be published

---

## Goal

The goal of this project is to provide a practical and maintainable baseline for secure self-hosted web infrastructure by focusing on:

* Reduced attack surface
* Controlled access paths
* Consistent monitoring
* Automated response to malicious activity

Security is achieved through the combination of these measures rather than a single component.
