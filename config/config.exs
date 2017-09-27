use Mix.Config

config :fide, :postgrex,
  database: "fast_import",
  username: "root",
  hostname: "localhost",
  name: :pg,
  pool: DBConnection.Poolboy,
  pool_size: 8
