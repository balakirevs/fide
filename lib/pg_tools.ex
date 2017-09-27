defmodule PgTools do
  
  def db_connection do
    {:ok, pid} = Postgrex.start_link(name: :pg, pool: DBConnection.Poolboy,
                                     pool_size: 8, hostname: "localhost",
                                     username: "abv", password: "abv",
                                     database: "fast_import")
  end

  def drop_records do
    Postgrex.transaction(:pg, fn conn ->
      Postgrex.query!(conn, "TRUNCATE words;", [])
    end, pool: DBConnection.Poolboy, pool_timeout: :infinity, timeout: :infinity)
  end
end
