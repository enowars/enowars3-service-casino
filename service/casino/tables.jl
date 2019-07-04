import JSON
using Sockets
include("strings.jl")
include("header.jl")

function update_table_list()
    let table_list
        if !(isfile("data/table_list.json"))
            table_list = Dict()
        else
            f = open_file_try("data/table_list.json", "r")
            table_list = JSON.parse(read(f, String))
            close(f)
        end
        for key in keys(table_list)
            table = table_list[key]
            #delete tables every 20 minutes
            if round(Int64, time()) - table["created"] > 1200
                delete!(table_list, key)
            end
        end
        f = open_file_try("data/table_list.json", "w")
        write(f, JSON.json(table_list))
        close(f)

        return table_list
    end
end
function get_table_list(p::Player)
    let table_list
        if !(isfile("data/table_list.json"))
            table_list = Dict()
        else
            f = open_file_try("data/table_list.json", "r")
            table_list = JSON.parse(read(f, String))
            close(f)
        end

        for key in keys(table_list)
            table = table_list[key]

            if table["game"] != string(p.current_game) || table["minimum"] > p.balance
                delete!(table_list, key)
            end
        end

        return table_list
    end
end

function join_table(p::Player)
    table_list = update_table_list()
    visible_tables = get_table_list(p)
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
        elseif s == "c"
            table = create_table(p)
            write(p.socket, "You approach the $(p.current_game) table $(table["name"]). The dealer smiles at you and slightly nods his head as a greeting.\n")
            break
        elseif haskey(visible_tables, s)
            table = visible_tables[s]
            write(p.socket, "You approach the $(p.current_game) table $(table["name"]). The dealer smiles at you and slightly nods his head as a greeting.\n")
            break
        elseif haskey(table_list, s) && table_list[s]["game"] == string(p.current_game)
            print_dict(p, "table_4")
            table = table_list[s]
            s = readline(p.socket)
            if table["passphrase"] == s
                write(p.socket, "You approach the $(p.current_game) table $(table["name"]). The dealer smiles at you and slightly nods his head as a greeting.\n")
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

function create_table(p::Player)
    table_list = update_table_list()

    print_dict(p, "table_12")
    let key, name, minimum, passphrase
        while true
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
            passphrase = readline(p.socket)
            if length(passphrase) > 24
                print_dict(p, "table_11")
            else
                break
            end
        end

        table_list[key] = Dict("name" => name, "minimum" => minimum, "passphrase" => passphrase, "game" => p.current_game, "created" => round(Int64, time()))

        f = open_file_try("data/table_list.json", "w")
        write(f, JSON.json(table_list))
        close(f)

        print_dict(p, "table_15")
        print_dict(p, "spacer")

        return table_list[key]
    end
end
