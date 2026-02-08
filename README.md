# chill base
A base of file storages and databases to support projects ecosystem

## Run
1. Create `.secrets/base.env` from `.env.example`

2. Create folders `data/s3`, `data/mongo`, `data/prometheus`, `data/loki`, `data/alloy`, `data/grafana`, `data/redis`, `data/sentry/redis`, `data/sentry/postgres`, `data/sentry/files`

3. Change configuration for MongoDB:
```
sudo sysctl -w vm.max_map_count=262144
```

4. Generate Relay credentials for Sentry ingestion:
`docker compose -p base run --rm --no-deps -T sentry-relay credentials generate --stdout > infra/sentry/relay/credentials.json`

5. Run `make up`

6. Set up domains `make set`

7. Set up all subdomains `sudo certbot --nginx`

8. Set up S3 buckets on `https://console.chill.services/`

9. Connect to MongoDB on `mongo mongo.chill.services -u <user> -p <pass> --authenticationDatabase admin`

10. Create Sentry admin user after stack startup:
`docker exec -it base-sentry-web sentry createuser --superuser --email <email>`
