use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :kdb, Kdb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Kafka configuration
config :kafka_ex,
  # a list of brokers to connect to in {"HOST", port} format
  brokers: [
    # {"192.168.99.100", 9092}
  ],
  # the default consumer group for worker processes, must be a binary (string)
  #    NOTE if you are on Kafka < 0.8.2 or if you want to disable the use of
  #    consumer groups, set this to :no_consumer_group (this is the
  #    only exception to the requirement that this value be a binary)
  # consumer_group: "kafka_ex",
  consumer_group: :no_consumer_group,
  # Set this value to true if you do not want the default
  # `KafkaEx.Server` worker to start during application start-up -
  # i.e., if you want to start your own set of named workers
  # disable_default_worker: false,
  disable_default_worker: true,
  # Timeout value, in msec, for synchronous operations (e.g., network calls)
  sync_timeout: 3000,
  # Supervision max_restarts - the maximum amount of restarts allowed in a time frame
  max_restarts: 10,
  # Supervision max_seconds -  the time frame in which :max_restarts applies
  max_seconds: 60,
  kafka_version: "0.8.2.1"
