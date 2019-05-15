import JSON
include("strings.jl")
include("header.jl")

function get_table_list(p::Player, g::Game)
    table_list = open("data/table_list.json", "r") do f
        s = read(f, String)
        table_list = JSON.parse(s)
    end
    for key in keys(table_list)
        table = table_list[key]
        if table["game"] != string(g) || table["minimum"] > p.balance
            delete!(table_list, key)
        end
    end

    return table_list
end

function join_table(p::Player, g::Game)

    return true
end

function create_table(p::Player, g::Game)

    return true
end
