function restaurant(p::Player)
    print_dict(p, "restaurant_intro")
    while true
        user_input = readline(p.socket)
        if (user_input == "c")
            counter(p)
            return
        elseif (user_input == "l")
            return
        elseif (user_input == "🧀")
            searchCheese(p)
        end
    end
end

function counter(p::Player)
    print_dict(p, "restaurant_counter")
    while true
        user_input = readline(p.socket)
        if (user_input == "l")
            return
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
