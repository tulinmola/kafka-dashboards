use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :kdb, Kdb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                    cd: Path.expand("../", __DIR__)]]


# Watch static and templates for browser reloading.
config :kdb, Kdb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

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
