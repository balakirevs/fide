# Fast data import and export with Elixir and Postgrex

#### Examples and comparison of different approaches of Import and Export data with Elixir and Postgrex - Elixir Hex package showcase

## Dataset size ~100_000 and 1_000_000 records

## Make a list of words

```
$ grep --fixed-strings '|' data.txt  # 99171 data.txt (number of words in the lib)
$ paste <(seq 1 99171) data.txt > data_with_ids.txt
$ head data_with_ids.txt
```

## Commands

```
$ cd ~/workspace
$ git clone git@github.com:balakirevs/fide.git
$ mix deps.get

$ createdb fast_import
$ psql fast_import
fast_import=# CREATE TABLE words(id integer not null primary key, word varchar not null);
```

## INSERT/COPY import into PostgreSQL

### import on a single process using INSERT

```
$ time mix run -e 'InsertImport.insert_import("./data_with_ids.txt")'

  results:
    ~100_000       |  ~1_000_000
  total   41.755   | total
  user    15.98s   | user
  sys     13.92s   | sys
  cpu     71%      | sys

```

### import on a single process using COPY

```
$ time mix run -e 'CopyImport.copy_import("./data_with_ids.txt")'
### results:
    ~100_000       |  1_000_000
  total   1.839s   | total  14.294s
  user    1.47s    | user   11.54s
  sys     0.60s    | sys    1.64s
  cpu     112%     | cpu    88%  
```

### concurrency import on 8 processes using INSERT

```
$ time mix run -e 'InsertImport.concurrency_insert_import("./data_with_ids.txt")'
# results:
    ~100_000       |  1_000_000   
  total   21.570s  | total   19:45.87
  user    27.38s   | user    730.32s
  sys     11.92s   | sys     201.06s
  cpu     182%     | cpu     78%
```

### concurrency import on 8 processes using COPY

```
$ time mix run -e 'CopyImport.concurrency_copy_import("./data_with_ids.txt")'
# results:
    ~100_000       |  1_000_000
  total   1.234s   | total  9.960s
  user    1.50s    | user   13.92s
  sys     0.60s    | sys    1.29s
  cpu     170%     | cpu    150%
```

## EXPORT from PostgreSQL

### export using COPY

```
$ time mix run -e 'ExportData.export("./out_data_with_ids.txt")'
$ wc -l out_data_with_ids.txt   # check up export data
# results:
    ~100_000       |  1_000_000
  total   0.671    | total   1.692s
  user    0.64s    | user    1.52s
  sys     0.31s    | sys     0.35s
  cpu     140%     | cpu     110%
```
