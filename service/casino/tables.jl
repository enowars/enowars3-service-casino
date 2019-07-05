import JSON
using Sockets
include("header.jl")

table_list = Dict()

function join_table(p::Player)
    global table_list
    let key_output
        key_output = ""
        for key in keys(table_list)
            table = table_list[key]
            if round(Int64, time()) - table["created"] > 1200
                delete!(table_list, key)
            elseif table["game"] != p.current_game || table["minimum"] > p.balance
                continue
            else
                key_output *= "$key\n"
            end
        end
        if key_output == ""
            print_dict(p, "table_3")
        else
            print_dict(p, "table_1")
            write(p.socket, key_output)
        end
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
        elseif haskey(table_list, s) && table_list[s]["game"] == p.current_game
            table = table_list[s]
            if table["minimum"] <= p.balance
                write(p.socket, "You approach the $(p.current_game) table $(table["name"]). The dealer smiles at you and slightly nods his head as a greeting.\n")
                break
            else
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
            end
        else
            print_dict(p, "repeat")
            continue
        end
    end
    return true
end

function create_table(p::Player)
    global table_list

    print_dict(p, "table_12")
    let key, name, minimum, passphrase
        while true
            key = readline(p.socket)
            if length(key) > 30
                print_dict(p, "table_13")
                continue
            elseif haskey(table_list,key)
                if round(Int64, time()) - table_list[key]["created"] <= 1200
                    print_dict(p, "table_14")
                    continue
                else
                    break
                end
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

        global table_list[key] = Dict("name" => name, "minimum" => minimum, "passphrase" => passphrase, "game" => p.current_game, "created" => round(Int64, time()))

        print_dict(p, "table_15")
        print_dict(p, "spacer")

        return table_list[key]
    end
end
