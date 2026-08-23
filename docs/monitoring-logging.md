# Monitoring and Logging

## Monitoring baseline

The current setup deliberately keeps monitoring simple and local. The main operational checks are based on:

- systemd service state
- nginx status and configuration validation
- Fail2Ban status
- HTTP response checks
- access and error logs
- normal operating-system health checks

A dedicated monitoring dashboard is optional rather than a required component of the architecture.

Useful health checks:

```bash
sudo systemctl --failed
sudo nginx -t
sudo fail2ban-client ping
sudo fail2ban-client status
```

## nginx log format

The repository provides the `main` log format in `nginx/http-context-example.conf`. It includes the resolved client address, request, response status, request time and forwarding information.

```nginx
log_format main '$remote_addr - $remote_user [$time_local] '
                '"$request" $status $body_bytes_sent '
                'rt=$request_time '
                '"$http_referer" "$http_user_agent" '
                '"$http_x_forwarded_for"';
```

Per-domain logs make troubleshooting and Fail2Ban filtering easier in a multi-site setup.

When nginx is behind a trusted edge/CDN, configure the real-IP module before relying on `$remote_addr` as the visitor address. Trust forwarded client-IP headers only from explicitly configured edge source ranges. After correct processing, `$remote_addr` is the restored visitor address and `$realip_remote_addr` remains the original TCP peer.

## Useful log commands

```bash
# Live traffic from all per-domain access logs
sudo tail -f /var/log/nginx/*access.log

# Common probes and leak attempts
sudo grep -Eh "\.git|\.env|backup|dump|xmlrpc|wp-login|wp-config|phpinfo|vendor/" /var/log/nginx/*access.log

# Top client IPs across all per-domain logs
sudo awk '{print $1}' /var/log/nginx/*access.log | sort | uniq -c | sort -nr | head

# Fail2Ban status
sudo fail2ban-client status
sudo fail2ban-client status nginx-badscan
```

References to WordPress-related paths in log searches are retained because scanners continue to request them even when WordPress is not installed.

## Fail2Ban and edge proxies

A log entry can contain the real visitor IP even though the network connection itself comes from a CDN/edge. In that layout, a normal local firewall ban of the restored visitor IP may not block future requests. Web jails are therefore disabled in the example until an ingress-appropriate local or provider-side action has been configured and tested.

## Functional validation

Monitoring should also include direct functional tests of the expected traffic path:

```bash
# Proxy to backend
curl -I -H "Host: example.com" http://backend.example.internal

# Public path
curl -I https://example.com
```

A healthy result means the required path works while unintended direct backend access remains blocked.
