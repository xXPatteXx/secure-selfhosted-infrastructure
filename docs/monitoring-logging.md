# Monitoring and Logging

## Monitoring

A practical baseline monitors:

- CPU, RAM, swap and disk I/O
- Network traffic
- nginx status
- systemd services
- Fail2Ban jails
- HTTP status codes and request rate

Monitoring should be internal-only or connected outbound to a trusted monitoring platform.

## nginx log format

```nginx
log_format main '$remote_addr - $remote_user [$time_local] '
                '"$request" $status $body_bytes_sent '
                'rt=$request_time '
                '"$http_referer" "$http_user_agent" '
                '"$http_x_forwarded_for"';
```

## Useful log commands

```bash
# Live traffic
sudo tail -f /var/log/nginx/access.log

# Common probes
sudo grep -E "wp-login|xmlrpc|\.git|\.env|wp-json" /var/log/nginx/access.log

# Top client IPs
sudo awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -nr | head

# Fail2Ban status
sudo fail2ban-client status
sudo fail2ban-client status nginx-badscan
```
