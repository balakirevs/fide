defmodule InsertImport do
  import PgTools

  def insert_import(filepath) do
    {:ok, pid} = Postgrex.start_link(hostname: "localhost",
                                     username: "abv", password: "abv",
                                     database: "fast_import")
    PgTools.db_connection()
    PgTools.drop_records()

    File.stream!(filepath)
    |> Stream.map(fn line ->
      [id_str, word] = line |> String.trim |> String.split("\t", trim: true, parts: 2)
      {id, ""} = Integer.parse(id_str)
      IO.inspect Postgrex.query!(pid, "INSERT INTO words(id, word) values($1, $2)", [id, word])
    end)
    |> Stream.run
  end

  def concurrency_insert_import(filepath) do
     PgTools.db_connection()
     PgTools.drop_records()

      File.stream!(filepath)
      |> Stream.map(fn line ->
        [id_str, word] = line |> String.trim |> String.split("\t", trim: true, parts: 2)

        {id, ""} = Integer.parse(id_str)

        [id, word]
      end)
      |> Stream.chunk(10_000, 10_000, [])
      |> Task.async_stream(fn word_rows ->
        Enum.each(word_rows, fn word_sql_params ->
        Postgrex.transaction(:pg, fn conn ->
          IO.inspect Postgrex.query!(conn, "INSERT INTO words(id, word) values($1, $2)", word_sql_params)
        end, pool: DBConnection.Poolboy, pool_timeout: :infinity, timeout: :infinity)
      end)
    end, max_concurrency: 8, timeout: :infinity)
    |> Stream.run
  end
end
