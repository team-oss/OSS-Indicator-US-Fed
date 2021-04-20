using LibPQ: Connection, execute, load!
using DataFrames
using VegaLite
using CSV

conn = Connection("dbname = sdad");
annual = DataFrame(execute(conn, String(read(joinpath("src", "assets", "sql", "03_pull_public.sql"))), not_null = true))

decade = DataFrame(execute(conn, String(read(joinpath("src", "assets", "sql", "03_pull_public_decade.sql"))), not_null = true))

plt = annual |>
    @vlplot(:point,
            x = :institution,
            y = :repos,
            color = :institution)
