function restaurant(p::Player)
    print_dict(p, "restaurant_intro")
    while true
        user_input = readline(p.socket)
        if (user_input == "c")
            counter(p)
            print_dict(p, "restaurant_intro")
        elseif (user_input == "l")
            return
        elseif (user_input == "🧀")
            searchCheese(p)
        end
    end
end

function checkToken(p::Player, code::String)
    token_json = JSON.parse(p.token, inttype=UInt8)
    enc_msg = UInt8.(token_json[1])

    cryptomaterial = generate_cryptomaterial(p)
    cryptomaterial[2] = UInt8.(token_json[2])


    println("Pre decrypt")
    msg = AESCBC(enc_msg, cryptomaterial[1], cryptomaterial[2], false)

    println("Decrypted")
    x = p.dimension % length(code)+1
    code = string(code[x+1:length(code)], code[1:x])

    println(code)

    msg = String(msg)
    msg = rstrip(msg, '\x00')
    println(msg)

    return msg == code

end

function checkTokenExistence(p::Player)
    return !(p.token == "")
end

function counter(p::Player)
    print_dict(p, "restaurant_counter")
    print_dict(p, "restaurant_menu")
    while true
        user_input = lowercase(readline(p.socket))
        if (user_input == "l")
            return
        elseif (user_input == "f")
            print_dict(p, "restaurant_flies_and_moths")
            return
        elseif (user_input == "r")
            print_dict(p, "restaurant_robot_choice")
            return
        elseif (user_input == "c")
            if !checkTokenExistence(p)
                print_dict(p, "restaurant_no_token")
                continue
            end
            if !checkToken(p, "CASINO_ROYALE")
                print_dict(p, "restaurant_token_fail")
                continue
            end
            print_dict(p, "restaurant_casino_royale")
            p.diarrhea = true
            #TODO print cheeseburger and activate hidden bathroom function
            elseif (user_input == "d")
            print_dict(p, "restaurant_dips_chips")
        else
            print_dict(p, "restaurant_invalid_input")
        end
    end
end

function searchCheese(p::Player)
    if !(isfile("data/.leaflet"))
        print_dict(p, "restaurant_cheese_fail")
    else
        print_dict(p, "restaurant_cheese")
        f = open("data/.leaflet", "r")
        write(p.socket, "$(read(f, String))\n")
        close(f)
    end
end
