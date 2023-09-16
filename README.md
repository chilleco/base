# chill base
A base of file storages and databases to support ecosystem projects

## Run
1. Create `.secrets/base.env` from `base.env`

2. Create folders `data/s3`, `data/mongo`, `data/redis`, `data/logs`

3. Create empty files `data/logs/mongodb.log`

4. Change configuration for MongoDB:
```
sudo sysctl -w vm.max_map_count=262144
```

5. Run `make run`

6. Set up domains `make set`

7. Set up all subdomains `sudo certbot --nginx`

8. Set up S3 buckets on `https://console.chill.services/`

9. Connect to MongoDB on `mongo mongo.chill.services -u <user> -p <pass> --authenticationDatabase admin`
