using Random
using Sockets
include("header.jl")
include("black_jack.jl")
include("slot_machine.jl")
include("roulette.jl")
include("withdraw.jl")
include("strings.jl")
include("cryptomat/cryptomat.jl")
include("tables.jl")
include("restaurant.jl")
include("bathroom.jl")

function gamble(p::Player)
    while true
        print_dict(p, "spacer")
        print_dict(p, "gamble_0")
        printGames(p)
        print_dict(p, "gamble_1")
        s = readline(p.socket)
        if s == ""
            print_dict(p, "repeat")
            continue
        elseif s == "black_jack"
            p.current_game = black_jack
            break
        elseif s == "slot_machine"
            p.current_game = slot_machine
            break
        elseif s == "roulette"
            p.current_game = roulette
            break
        else
            print_dict(p, "irritated")
            print_dict(p, "repeat")
            continue
        end
    end
    print_dict(p, "spacer")
    while true
        if p.current_game == slot_machine
            break
        end
        print_dict(p, "table_0")
        s = readline(p.socket)
        if s == ""
            print_dict(p, "repeat")
            continue
        elseif s == "j"
            if join_table(p)
                break
            else
                print_dict(p, "gamble_3")
                p.status = reception
                return
            end

        elseif s == "c"
            create_table(p)
            continue
        else
            print_dict(p, "irritated")
            print_dict(p, "repeat")
            continue
        end
    end

    if p.current_game == black_jack
        print_dict(p, "black_jack_welcome")
    elseif p.current_game == slot_machine
        print_dict(p, "slot_machine_welcome")
    elseif p.current_game == roulette
        print_dict(p, "roulette_welcome")
    end

    while true
        print_dict(p, "spacer")
        if p.current_game == black_jack
            play_black_jack(p)
        elseif p.current_game == slot_machine
            play_slot_machine(p)
        elseif p.current_game == roulette
            play_roulette(p)
        end

        if p.status == reception
            print_dict(p, "gamble_4")
            return
        end
        while true
            print_dict(p, "gamble_2")
            s = readline(p.socket)
            if s == ""
                print_dict(p, "repeat")
                continue
            elseif s == "n"
                print_dict(p, "gamble_3")
                p.status = reception
                return
            elseif s == "y"
                break
            else
                print_dict(p, "irritated")
                print_dict(p, "repeat")
                continue
            end
        end
    end
end


function receptionDesk(p::Player)
    print_dict(p, "spacer")
    printBalance(p)
    print_dict(p, "reception_0")
    s = readline(p.socket)
    if s == ""
        print_dict(p, "reception_1")
    elseif s == "g"
        p.status = gambling
    elseif s == "w"
        withdraw(p)
    elseif s == "b"
        print_dict(p, "reception_2")
        bathroom(p)
    elseif s == "r"
        restaurant(p)
    elseif s == "l"
        print_dict(p, "spacer")
        if p.balance < 0
            print_dict(p, "debt_1")
        else
            print_dict(p, "exit")
            close(p.socket)
        end
    end
end

function main(socket)
    p = Player(0, reception, slot_machine, socket, rand(Int), "", "", false)
    print_dict(p, "spacer")
    print_dict(p, "welcome")
    while true
        if p.status == reception
            receptionDesk(p)
        elseif p.status == gambling
            gamble(p)
        end
    end
end
####################################
####################################

server = listen(IPv6(0),6969)
println("Waiting for people to enter the casino..")
while true
    socket = accept(server)
    println("Accepted: $(getsockname(socket))")
    @async begin
        try
            main(socket)
        catch err
            println("connection ended with $err")
        end
    end
end
