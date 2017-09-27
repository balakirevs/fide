defmodule ExportData do
  import PgTools

  def export(filepath) do
    PgTools.db_connection

    Postgrex.transaction(:pg, fn conn ->
      pg_copy = Postgrex.stream(conn, "COPY (SELECT id, word FROM WORDS) TO STDOUT", [])

      pg_copy
      |> Enum.map(fn %Postgrex.Result{rows: rows} -> rows end)
      |> Enum.into(File.stream!(filepath))

    end, pool: DBConnection.Poolboy, pool_timeout: :infinity, timeout: :infinity)
  end
end
