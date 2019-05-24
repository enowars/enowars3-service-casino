using Random
using Sockets
include("header.jl")
include("black_jack.jl")
include("slot_machine.jl")
include("roulette.jl")
include("strings.jl")
include("cryptomat/cryptomat.jl")
include("tables.jl")

function gamble(p::Player)
    while true
        global current_game
        print_dict(p, "spacer")
        print_dict(p, "gamble_0")
        printGames(p)
        print_dict(p, "gamble_1")
        current_game = readline(p.socket)
        if current_game == ""
            print_dict(p, "repeat")
            continue
        elseif current_game == "black_jack"
            current_game = black_jack
            break
        elseif current_game == "slot_machine"
            current_game = slot_machine
            break
        elseif current_game == "roulette"
            current_game = roulette
            break
        else
            print_dict(p, "irritated")
            print_dict(p, "repeat")
            continue
        end
    end
    print_dict(p, "spacer")
    while true
        if current_game == slot_machine
            break
        end
        print_dict(p, "table_0")
        s = readline(p.socket)
        if s == ""
            print_dict(p, "repeat")
            continue
        elseif s == "j"
            if join_table(p, current_game)
                break
            else
                print_dict(p, "gamble_3")
                p.status = reception
                return
            end

        elseif s == "c"
            create_table(p, current_game)
            continue
        else
            print_dict(p, "irritated")
            print_dict(p, "repeat")
            continue
        end
    end

    while true
        print_dict(p, "spacer")
        if current_game == black_jack
            play_black_jack(p)
        elseif current_game == slot_machine
            play_slot_machine(p)
        elseif current_game == roulette
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
function withdraw(p::Player)
    print_dict(p, "spacer")
    print_dict(p, "withdraw_0")
    s = readline(p.socket)
    amount = tryparse(Int64, s)
    if amount == nothing || amount <= 0
        print_dict(p, "withdraw_1")
        return
    end
    p.balance += amount

    if p.balance > 10000
        print_dict(p, "withdraw_2")
        p.balance = 10000
    end
end

function bathroom(p::Player)
    print_dict(p, "spacer")
    print_dict(p, "bathroom_0")
    s = readline(p.socket)
    if s == "w"
        print_dict(p, "bathroom_1")
    elseif s == "l"
        print_dict(p, "bathroom_2")
    else
        print_dict(p, "bathroom_3")
        return
    end

    print_dict(p, "bathroom_4")

    s = readline(p.socket)
    if s == "v"
        print_dict(p, "spacer")
        use_cryptomat(p)
    elseif s == "r"
        p.status = reception
    end

    print_dict(p, "bathroom_5")
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
    elseif s == "l"
        close(p.socket)
    end
end

function main(socket)
    p = Player(0, reception, socket, rand(Int), "")
    write(p.socket, "Entering...")
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
while true
    socket = accept(server)
    @async begin
        try
            main(socket)
        catch err
            print("connection ended with $err")
        end
    end
end
