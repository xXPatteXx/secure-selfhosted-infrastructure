# Networking

## Intended traffic flow

```text
Public client
  → Trusted Edge
  → Gateway / Firewall
  → Reverse Proxy
  → Internal Backend
```

The backend network is treated as a separate trust zone. Client systems should not have unrestricted direct access to it.

## Access model

| Flow | Expected result |
|---|---|
| Trusted edge → reverse proxy HTTP/HTTPS | allowed |
| Reverse proxy → backend HTTP | allowed |
| Client network → backend directly | blocked |
| Backend → another backend HTTP | blocked unless explicitly required |
| Management path → SSH | allowed |
| Backend → DNS / package repositories | allowed outbound |
| Internet → backend directly | blocked |
| Unknown hostname → reverse proxy | rejected |

## Firewall baseline

### Reverse proxy

Typical inbound policy:

| Service | Port | Allowed source |
|---|---:|---|
| SSH | 22/tcp | explicit management source/path |
| HTTP | 80/tcp | trusted edge / controlled ingress |
| HTTPS | 443/tcp | trusted edge / controlled ingress |

If the origin is restricted to edge networks, certificate validation must still follow a working path. For ACME HTTP-01, either make sure the challenge request reaches the origin through the edge or use another challenge type such as DNS-01. Do not silently open the complete origin just to make renewal work.

### Backend servers

Typical inbound policy:

| Service | Port | Allowed source |
|---|---:|---|
| SSH | 22/tcp | internal management path only |
| HTTP | 80/tcp | reverse proxy only |

Default inbound policy remains deny. Outbound traffic can be allowed for maintenance while keeping inbound exposure unchanged.

## Trusted client addresses

When nginx sits behind a proxy/CDN, the TCP peer is normally the edge rather than the original visitor. If application logs or downstream services need the original client address, configure nginx's real-IP module with the exact trusted edge ranges and the header documented by that provider.

The important rule is:

```text
forwarded client IP + trusted TCP source → may be accepted
forwarded client IP + arbitrary TCP source → must not be trusted
```

After correct real-IP processing, `$remote_addr` represents the restored client address while `$realip_remote_addr` preserves the original TCP peer address.

## Outbound maintenance traffic

Backend servers need a valid default route and DNS configuration to perform tasks such as:

```bash
sudo apt update
sudo apt upgrade
```

Allowing a backend to initiate outbound connections does not require publishing that backend to the internet. Inbound firewall rules remain the controlling boundary for unsolicited traffic.

## Network isolation

Where the gateway supports network isolation, client and backend networks should be separated. Administrative access can then be provided through explicit management paths instead of broad inter-network routing.

This gives a useful distinction between:

```text
normal client traffic     → blocked from backend network
administrative traffic    → allowed only through defined path
proxy application traffic → allowed only to required backend service
```

## IPv6 note

If IPv6 is not part of the production design, disable DHCPv6/router advertisements on relevant interfaces or implement equivalent IPv6 firewall policy. Avoid relying on IPv4 filtering while leaving an unmanaged IPv6 path available.

The example nginx listeners include IPv4 and IPv6. Remove the IPv6 listeners only when IPv6 is deliberately disabled at the system/network level.

## Validation commands

```bash
ip addr
ip route
resolvectl status
ss -tulpen
sudo ufw status verbose
```

Validate both successful and blocked paths. A secure result is not only that the application works, but also that unintended paths fail.
