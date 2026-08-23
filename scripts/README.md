# Operational helper scripts

- `check-nginx.sh` validates nginx configuration and service state.
- `check-certbot.sh` checks the Certbot timer and performs a renewal dry run.
- `analyze-nginx-logs.sh` summarizes client addresses and common probe requests across per-domain access logs by default. Pass one or more explicit log files as arguments to override the default.
