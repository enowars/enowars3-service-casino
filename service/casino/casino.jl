using Random
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
        print_dict("spacer")
        print_dict("gamble_0")
        printGames()
        print_dict("gamble_1")
        current_game = readline()
        if current_game == ""
            print_dict("repeat")
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
            print_dict("irritated")
            print_dict("repeat")
            continue
        end
    end
    print_dict("spacer")
    while true
        if current_game == slot_machine
            break
        end
        print_dict("table_0")
        s = readline()
        if s == ""
            print_dict("repeat")
            continue
        elseif s == "j"
            if join_table(p, current_game)
                break
            else
                print_dict("gamble_3")
                p.status = reception
                return
            end

        elseif s == "c"
            create_table(p, current_game)
            continue
        else
            print_dict("irritated")
            print_dict("repeat")
            continue
        end
    end

    while true
        print_dict("spacer")
        if current_game == black_jack
            play_black_jack(p)
        elseif current_game == slot_machine
            play_slot_machine(p)
        elseif current_game == roulette
            play_roulette(p)
        end

        if p.status == reception
            print_dict("gamble_4")
            return
        end
        while true
            print_dict("gamble_2")
            s = readline()
            if s == ""
                print_dict("repeat")
                continue
            elseif s == "n"
                print_dict("gamble_3")
                p.status = reception
                return
            elseif s == "y"
                break
            else
                print_dict("irritated")
                print_dict("repeat")
                continue
            end
        end
    end
end
function withdraw(p::Player)
    print_dict("spacer")
    print_dict("withdraw_0")
    s = readline()
    amount = tryparse(Int64, s)
    if amount == nothing || amount <= 0
        print_dict("withdraw_1")
        return
    end
    p.balance += amount

    if p.balance > 10000
        print_dict("withdraw_2")
        p.balance = 10000
    end
end

function bathroom(p::Player)
    print_dict("spacer")
    print_dict("bathroom_0")
    s = readline()
    if s == "w"
        print_dict("bathroom_1")
    elseif s == "l"
        print_dict("bathroom_2")
    else
        print_dict("bathroom_3")
        return
    end

    print_dict("bathroom_4")

    s = readline()
    if s == "v"
        print_dict("spacer")
        use_cryptomat()
    elseif s == "r"
        p.status = reception
    end

    print_dict("bathroom_5")
end

function receptionDesk(p::Player)
    print_dict("spacer")
    printBalance(p)
    print_dict("reception_0")
    s = readline()
    if s == ""
        print_dict("reception_1")
    elseif s == "g"
        p.status = gambling
    elseif s == "w"
        withdraw(p)
    elseif s == "b"
        print_dict("reception_2")
        bathroom(p)
    elseif s == "l"
        exit(0)
    end
end

function main()
    p = Player(0,reception)
    print_dict("spacer")
    print_dict("welcome")
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
global dimension = rand(Int)
main()
