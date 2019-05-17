import JSON
include("strings.jl")
include("header.jl")
function update_table_list()
    table_list = open("data/table_list.json", "r") do f
        s = read(f, String)
        table_list = JSON.parse(s)
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
    table_list = update_table_list()
    visible_tables = get_table_list(p,g)
    if size(collect(keys(visible_tables)),1) == 0
        printDict(("table",3))
    else
        printDict(("table",1))
        for key in keys(visible_tables)
            println(key)
        end
    end
    while true
        printDict(("table",2))
        s = readline()
        if s == ""
            printDict("repeat")
            continue
        elseif s == "l"
            return false
        elseif haskey(visible_tables, s)
            table = visible_tables[s]
            println("You approach the ", g," table ", table["name"],". The dealer smiles at you and slightly nods his head as a greeting.")
            break
        elseif haskey(table_list, s) && table_list[s]["game"] == string(g)
            printDict(("table",4))
            table = table_list[s]
            s = readline()
            if table["passphrase"] == s
                println("You approach the ", g," table ", table["name"],". The dealer smiles at you and slightly nods his head as a greeting.")
                break;
            else
                printDict(("table", 5))
                continue
            end
        else
            printDict("repeat")
            continue
        end
    end
    return true
end

function create_table(p::Player, g::Game)
    table_list = update_table_list()

    printDict(("table", 12))
    while true
        global key
        key = readline()
        if length(key) > 10
            printDict(("table",13))
            continue
        elseif haskey(table_list,key)
            printDict(("table",14))
            continue
        else
            break
        end
    end

    printDict(("table", 6))
    while true
        global name
        name = readline()

        if length(name) > 64
            printDict("table", 7)
            continue
        else
            break
        end
    end
    printDict(("table", 8))
    while true
        global minimum
        s = readline()
        minimum = tryparse(Int, s)
        if minimum == nothing || minimum < 1
            printDict(("table", 9))
            continue
        else
            break
        end
    end
    printDict(("table", 10))
    while true
        global passphrase
        passphrase = readline()
        if length(passphrase) > 24
            printDict(("table",11))
        else
            break
        end
    end

    table_list[key] = Dict("name" => name, "minimum" => minimum, "passphrase" => passphrase, "game" => g, "created" => round(Int64, time() * 1000))

    open("data/table_list.json", "w") do f
        s = JSON.json(table_list)
        write(f, s)
    end

    printDict(("table", 15))
    printDict("spacer")
end
