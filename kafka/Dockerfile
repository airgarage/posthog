FROM docker.redpanda.com/redpandadata/redpanda:v25.1.9

CMD ["redpanda", "start", "--mode", "dev-container", "--kafka-addr", "internal://0.0.0.0:9092", "--advertise-kafka-addr", "internal://posthog-kafka:9092"]