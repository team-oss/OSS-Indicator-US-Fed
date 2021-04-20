using CSV, DataFrames, URIs
using LibPQ: Connection, execute, load!

conn = Connection("dbname = sdad")

lns = readlines(joinpath("data", "oss", "working", "us_fed.tsv"))
lns = lns[2:end]
lns[findfirst(x -> occursin("Other agencies", x), lns):length(lns)] .=
    replace.(lns[findfirst(x -> occursin("Other agencies", x), lns):length(lns)], r"^\s+" => "")
filter!(x -> !endswith(x, '\t'), lns)
name_website = split.(lns, '\t')
filter!(x -> !isempty(x[2]), name_website)
top_level = findall(x -> startswith(x, r"[^ ]"), lns)
entity_levels = [ top_level[idx]:(top_level[idx + (idx < length(top_level))] - (idx < length(top_level))) for idx in 1:length(top_level) ]
x = name_website[entity_levels[2]]

function find_domains(name_website)
    data = DataFrame(domain = unique(URI(name_website[2]).host for name_website in name_website))
    data[!,:dept_agency] .= name_website[1][1]
    data
end
data = reduce(vcat, find_domains(name_website[elem]) for elem in entity_levels)
sort!(data)

execute(conn, "TRUNCATE gh_2007_2019.us_fed;")
load!(data, conn, string("INSERT INTO gh_2007_2019.us_fed VALUES(", join(("\$$i" for i in 1:size(data, 2)), ','), ");"))

DataFrame(domain = unique(match(r"(?<=\.)?[^\.]+(?=\.\w{3}$)", URI(name_website[2]).host).match for name_website in name_website[entity_levels[2]]))


foreach(println, sort!(unique(Base.Iterators.flatten(data[!,2]))))

data[34,:]

findfirst(x -> "si" ∈ x, data[!,2])


x[1][1], unique(match(r"(?<=\.)\w+(?=\.(gov|mil)(/|$))", name_website[2]).match for name_website in x)

for x in entity_levels
    println(x)
    find_domains(name_website[x])
end

foreach(println, last.(name_website[1:6]))

unique(match(r"(?<=\.)[^\.]+(?=\.\w{3}$)", URI(name_website[2]).host).match for name_website in name_website[63:64])

URI(name_website[62][2]).host
match(r"(?<=\.)?[^\.]+(?=\.\w{3}$)", URI(name_website[64][2]).host).match


match(r"\w+$", URI("https://www.ahrq.gov/").host).match


[ top_level[idx]:(top_level[idx + 1] - 1) for idx in eachindex(top_level)[begin:end - 1] ]
entities = [ lns[top_level[idx]:top_level[idx] - 1]
