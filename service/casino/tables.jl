import JSON
using Sockets
include("strings.jl")
include("header.jl")

function update_table_list()
    global table_list
    try
        table_list = open("data/table_list.json", "r") do f
            s = read(f, String)
            table_list = JSON.parse(s)
        end
    catch
        table_list = Dict()
    end
    for key in keys(table_list)
        table = table_list[key]
        if round(Int64, time() * 1000) - table["created"] > 600000
            delete!(table_list, key)
        end
    end
    open("data/table_list.json", "w") do f
        s = JSON.json(table_list)
        write(f, s)
    end

    return table_list
end
function get_table_list(p::Player, g::Game)
    global table_list
    try
        table_list = open("data/table_list.json", "r") do f
            s = read(f, String)
            table_list = JSON.parse(s)
        end
    catch
        table_list = Dict()
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
    table_list = update_table_list()
    visible_tables = get_table_list(p,g)
    if size(collect(keys(visible_tables)),1) == 0
        print_dict(p, "table_3")
    else
        print_dict(p, "table_1")
        key_output = ""
        for key in keys(visible_tables)

            key_output *= "$key\n"
        end
        write(p.socket, key_output)
    end
    while true
        print_dict(p, "table_2")
        s = readline(p.socket)
        if s == ""
            print_dict(p, "repeat")
            continue
        elseif s == "l"
            return false
        elseif haskey(visible_tables, s)
            table = visible_tables[s]
            write(p.socket, "You approach the $g table $(table["name"]). The dealer smiles at you and slightly nods his head as a greeting.\n")
            break
        elseif haskey(table_list, s) && table_list[s]["game"] == string(g)
            print_dict(p, "table_4")
            table = table_list[s]
            s = readline(p.socket)
            if table["passphrase"] == s
                write(p.socket, "You approach the $g table $(table["name"]). The dealer smiles at you and slightly nods his head as a greeting.\n")
                break;
            else
                print_dict(p, "table_5")
                continue
            end
        else
            print_dict(p, "repeat")
            continue
        end
    end
    return true
end

function create_table(p::Player, g::Game)
    table_list = update_table_list()

    print_dict(p, "table_12")
    while true
        global key
        key = readline(p.socket)
        if length(key) > 30
            print_dict(p, "table_13")
            continue
        elseif haskey(table_list,key)
            print_dict(p, "table_14")
            continue
        else
            break
        end
    end

    print_dict(p, "table_6")
    while true
        global name
        name = readline(p.socket)

        if length(name) > 64
            print_dict(p, "table_7")
            continue
        else
            break
        end
    end
    print_dict(p, "table_8")
    while true
        global minimum
        s = readline(p.socket)
        minimum = tryparse(Int, s)
        if minimum == nothing || minimum < 1
            print_dict(p, "table_9")
            continue
        else
            break
        end
    end
    print_dict(p, "table_10")
    while true
        global passphrase
        passphrase = readline(p.socket)
        if length(passphrase) > 24
            print_dict(p, "table_11")
        else
            break
        end
    end

    table_list[key] = Dict("name" => name, "minimum" => minimum, "passphrase" => passphrase, "game" => g, "created" => round(Int64, time() * 1000))

    open("data/table_list.json", "w") do f
        s = JSON.json(table_list)
        write(f, s)
    end

    print_dict(p, "table_15")
    print_dict(p, "spacer")
end
