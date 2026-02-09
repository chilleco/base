from sentry.conf.server import *  # NOQA

# Keep a minimal self-hosted configuration in-repo so Sentry services
# consistently use the internal Kafka/Snuba/Redis stack defined in compose.

SENTRY_SINGLE_ORGANIZATION = env("SENTRY_SINGLE_ORGANIZATION", "1") in ("1", "true", "True")
SENTRY_OPTIONS["system.event-retention-days"] = int(env("SENTRY_EVENT_RETENTION_DAYS", "30"))

secret_key = env("SENTRY_SECRET_KEY", "")
if secret_key:
    SENTRY_OPTIONS["system.secret-key"] = secret_key

SENTRY_OPTIONS["redis.clusters"] = {
    "default": {
        "hosts": {
            0: {
                "host": env("SENTRY_REDIS_HOST", "sentry-redis"),
                "port": env("SENTRY_REDIS_PORT", "6379"),
                "db": "0",
            }
        }
    }
}

DEFAULT_KAFKA_OPTIONS = {
    "bootstrap.servers": env("SENTRY_KAFKA_BROKERS", "sentry-kafka:9092"),
    "message.max.bytes": 50000000,
    "socket.timeout.ms": 1000,
}

SENTRY_EVENTSTREAM = "sentry.eventstream.kafka.KafkaEventStream"
SENTRY_EVENTSTREAM_OPTIONS = {"producer_configuration": DEFAULT_KAFKA_OPTIONS}
KAFKA_CLUSTERS["default"] = DEFAULT_KAFKA_OPTIONS

SENTRY_SEARCH = "sentry.search.snuba.EventsDatasetSnubaSearchBackend"
SENTRY_SEARCH_OPTIONS = {}
SENTRY_TAGSTORE_OPTIONS = {}
SENTRY_TSDB = "sentry.tsdb.redissnuba.RedisSnubaTSDB"

SENTRY_WEB_HOST = "0.0.0.0"
SENTRY_WEB_PORT = 9000
