include .env

up:
	docker compose -p base up --build -d

down:
	docker compose -p base stop

status:
	docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

mongo:
	docker exec -it `docker ps -a | grep base-mongo | cut -d ' ' -f 1` mongosh -u ${MONGO_USER} -p ${MONGO_PASS}

# TODO: logs:

set:
	sudo chmod 0755 ~
	sudo chmod -R a+w ~/data/
	sudo chmod 0700 ~/.ssh
	sudo chmod -R 0600 ~/.ssh/*
	export EXTERNAL_HOST=${EXTERNAL_HOST} DATA_PATH=${DATA_PATH} PROMETHEUS_PORT=${PROMETHEUS_PORT} GRAFANA_PORT=${GRAFANA_PORT}; \
	envsubst '$${EXTERNAL_HOST} $${DATA_PATH} $${PROMETHEUS_PORT} $${GRAFANA_PORT}' < infra/nginx/prod.conf > /etc/nginx/sites-enabled/base.conf
	sudo systemctl restart nginx
	sudo certbot --nginx
