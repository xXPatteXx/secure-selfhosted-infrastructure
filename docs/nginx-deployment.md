# nginx Deployment Notes

The example files are intentionally split by configuration scope.

## 1. `http {}` context

Place the directives from `nginx/http-context-example.conf` inside the nginx `http {}` context or in a file that your distribution includes from that context.

Before enabling real-IP processing:

1. Replace the documentation-only trusted ranges with the current networks of the actual edge/CDN.
2. Use the client-IP header documented by that provider.
3. Keep the trusted source list narrow; never use `0.0.0.0/0` or `::/0` for forwarded client addresses.

## 2. Catch-all servers

Install `nginx/default-deny.conf` as an enabled site/server configuration and remove or disable any conflicting distribution-provided default server.

Unknown HTTP hostnames should receive connection-close behavior (`444`), while unknown HTTPS SNI names are rejected during the TLS handshake.

## 3. Application vHosts

Adapt `nginx/reverse-proxy-example.conf` for each application:

- replace domain and backend placeholders
- verify certificate paths
- keep backend routing limited to the intended service
- add application-specific headers or CSP only after testing

The example targets nginx 1.25.1+ because it uses `http2 on;`.

## 4. Validate

```bash
sudo nginx -t
sudo systemctl reload nginx
sudo systemctl --failed
```

Then verify both expected and rejected behavior:

```bash
curl -I https://example.com
curl -I -H 'Host: example.com' http://backend.example.internal
curl -I -H 'Host: unknown.invalid' http://127.0.0.1
```

Also test from network locations that should not be able to reach the backend directly.
