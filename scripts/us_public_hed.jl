using CSV, DataFrames, LibPQ

ipeds_public_hed = CSV.read(joinpath("data", "oss", "working", "ipeds_public_hed.csv"), DataFrame)

conn = LibPQ.Connection("dbname = sdad")

execute(conn, "BEGIN;")
LibPQ.load!(ipeds_public_hed[!,[1,2,4]], conn, "insert into gh_2007_2019.us_ipeds_public_hed values(\$1,\$2,\$3);")
execute(conn, "COMMIT;")
