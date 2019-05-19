include("sender.jl")
include("os_updater.jl")
include("../strings.jl")

function use_cryptomat()
    print_dict("cryptomat_0")
    global note_max_length = 2
    global msg = ""
    while true
        user_input = readline()
        if ("1" <= user_input <= "5") || ("١" <= user_input <= "٥")
            sendSecret(parse(Int, user_input), msg)
            print_dict("cryptomat_0")
        elseif user_input == "u"
            print_dict("cryptomat_1")
            msg = readline()
            print_dict("cryptomat_0")
        elseif user_input == "c"
            msg = ""
        elseif user_input == "r"
            print_dict("cryptomat_0")
            continue
        elseif user_input == "o"
            updateOS()
            print_dict("cryptomat_0")
        elseif user_input == "l"
            break
        elseif user_input == "◈"
            if !(isfile("data/.note"))
                print_dict("cryptomat_2")
            else
                print_dict("cryptomat_3")
                f = open("data/.note", "r")
                println(JSON.parse(read(f, String)))
                close(f)
            end
        elseif user_input == "🕐"
            update = readline()
            try
                global dimension = parse(Int, update)
            catch
                continue
            end
        else
            print_dict("cryptomat_4")
        end
    end
    print_dict("cryptomat_5")
end
