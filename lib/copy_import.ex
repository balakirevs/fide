defmodule CopyImport do
  import PgTools

  def copy_import(filepath) do
    PgTools.db_connection()
    PgTools.drop_records()

    Postgrex.transaction(:pg, fn conn ->
      pg_copy = Postgrex.stream(conn, "COPY words(id, word) FROM STDIN", [])

      File.stream!(filepath)
      |> Enum.map(fn line ->
        [id, word] = line |> String.trim |> String.split("\t", trim: true, parts: 2)
        [id, ?\t, word, ?\n]
      end)
      |> Enum.into(pg_copy)

    end, pool: DBConnection.Poolboy, pool_timeout: :infinity, timeout: :infinity)
  end

  def concurrency_copy_import(filepath) do
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
       Postgrex.transaction(:pg, fn conn ->
         pg_copy = Postgrex.stream(conn, "COPY words(id, word) FROM STDIN", [])

         word_rows
         |> Enum.map(fn [id, word] ->
           [to_string(id), ?\t, word, ?\n] end)
         |> Enum.into(pg_copy)

       end, pool: DBConnection.Poolboy, pool_timeout: :infinity, timeout: :infinity)
     end, max_concurrency: 8, timeout: :infinity)
     |> Stream.run
   end
end
