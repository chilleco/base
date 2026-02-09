# chill base
A base of file storages and databases to support projects ecosystem

## Run
1. Create `.secrets/base.env` from `.env.example`

2. Create folders `data/s3`, `data/mongo`, `data/prometheus`, `data/loki`, `data/alloy`, `data/grafana`, `data/redis`, `data/sentry/redis`, `data/sentry/postgres`, `data/sentry/files`, `data/sentry/kafka`, `data/sentry/clickhouse`, `data/sentry/clickhouse-log`

3. Change configuration for MongoDB:
```
sudo sysctl -w vm.max_map_count=262144
```

4. Run `make up` (it auto-generates `infra/sentry/relay/credentials.json` on first run; first Sentry start also runs Snuba bootstrap and can take a few minutes)

5. Set up domains `make set`

6. Set up all subdomains `sudo certbot --nginx`

7. Set up S3 buckets on `https://console.chill.services/`

8. Connect to MongoDB on `mongo mongo.chill.services -u <user> -p <pass> --authenticationDatabase admin`

9. Create Sentry admin user after stack startup:
`docker exec -it base-sentry-web sentry createuser --superuser --email <email>`

10. SMTP is optional for Sentry startup; leave `SENTRY_SMTP_*` empty if you do not need email notifications.
