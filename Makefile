include .env

# ============================================================================
# Deployment
# ============================================================================

.PHONY: set
set:
	sudo chmod 0755 ~
	sudo chmod -R a+w ~/data/
	sudo chmod 0700 ~/.ssh
	sudo chmod -R 0600 ~/.ssh/*
	export EXTERNAL_HOST=${EXTERNAL_HOST} DATA_PATH=${DATA_PATH} PROMETHEUS_PORT=${PROMETHEUS_PORT} GRAFANA_PORT=${GRAFANA_PORT} SENTRY_PORT=${SENTRY_PORT}; \
	envsubst '$${EXTERNAL_HOST} $${DATA_PATH} $${PROMETHEUS_PORT} $${GRAFANA_PORT} $${SENTRY_PORT}' < infra/nginx/prod.conf > /etc/nginx/sites-enabled/base.conf
	sudo systemctl restart nginx
	sudo certbot --nginx


.PHONY: certs
certs:
	sudo systemctl restart nginx
	sudo certbot --nginx

# ============================================================================
# Lifecycle
# ============================================================================

up:
	docker compose -p base up --build -d

down:
	docker compose -p base stop

# ============================================================================
# Status and monitoring
# ============================================================================

status:
	docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

# ============================================================================
# Logs
# ============================================================================

# TODO: logs:

# ============================================================================
# Development tools
# ============================================================================

mongo:
	docker exec -it `docker ps -a | grep base-mongo | cut -d ' ' -f 1` mongosh -u ${MONGO_USER} -p ${MONGO_PASS}
