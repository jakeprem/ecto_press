import Config

config :examples, Examples.Repo,
  database: Path.expand("../examples.db", __DIR__),
  pool_size: 5,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

config :examples,
  ecto_repos: [Examples.Repo]
