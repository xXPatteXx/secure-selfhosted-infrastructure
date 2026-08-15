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

A useful log format includes the client address, request, response status, request time and forwarding information.

```nginx
log_format main '$remote_addr - $remote_user [$time_local] '
                '"$request" $status $body_bytes_sent '
                'rt=$request_time '
                '"$http_referer" "$http_user_agent" '
                '"$http_x_forwarded_for"';
```

Per-domain logs make troubleshooting and Fail2Ban filtering easier in a multi-site setup.

## Useful log commands

```bash
# Live traffic
sudo tail -f /var/log/nginx/access.log

# Common probes and leak attempts
sudo grep -E "\.git|\.env|backup|dump|xmlrpc|wp-login" /var/log/nginx/access.log

# Top client IPs
sudo awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr | head

# Fail2Ban status
sudo fail2ban-client status
sudo fail2ban-client status nginx-badscan
```

References to WordPress-related paths in log searches are retained because scanners continue to request them even when WordPress is not installed.

## Functional validation

Monitoring should also include direct functional tests of the expected traffic path:

```bash
# Proxy to backend
curl -I -H "Host: example.com" http://backend.example.internal

# Public path
curl -I https://example.com
```

A healthy result means the required path works while unintended direct backend access remains blocked.
