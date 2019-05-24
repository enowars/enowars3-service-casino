using Sockets
include("sender.jl")
include("os_updater.jl")
include("../strings.jl")

function use_cryptomat(p::Player)
    print_dict(p, "cryptomat_0")
    global note_max_length = 10
    p.msg = ""
    while true
        user_input = readline(p.socket)
        #if ("1" <= user_input <= "5") || ("١" <= user_input <= "٥")
        if (user_input == "3") || (user_input == "٣")
            sendSecret(p, parse(Int, user_input), p.msg)
            print_dict(p, "cryptomat_0")
        elseif user_input == "u"
            print_dict(p, "cryptomat_1")
            p.msg = readline(p.socket)
            print_dict(p, "cryptomat_0")
        elseif user_input == "c"
            p.msg = ""
        elseif user_input == "r"
            print_dict(p, "cryptomat_0")
            continue
        elseif user_input == "o"
            updateOS(p)
            print_dict(p, "cryptomat_0")
        elseif user_input == "l"
            break
        elseif user_input == "◈"
            if !(isfile("data/.note"))
                print_dict(p, "cryptomat_2")
            else
                print_dict(p, "cryptomat_3")
                f = open("data/.note", "r")
                write(p.socket, "$(read(f, String))\n")
                close(f)
            end
        elseif user_input == "🕐"
            update = readline(p.socket)
            try
                p.dimension = parse(Int, update)
            catch
                continue
            end
        else
            print_dict(p, "cryptomat_4")
        end
    end
    print_dict(p, "cryptomat_5")
end
