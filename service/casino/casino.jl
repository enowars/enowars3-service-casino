using Random
include("header.jl")
include("black_jack.jl")
include("slot_machine.jl")
include("strings.jl")
include("cryptomat/cryptomat.jl")

function gamble(p::Player)
    current_game = ""
    while true
        printDict("spacer")
        printDict(("gamble", 0))
        printGames()
        printDict(("gamble", 1))
        current_game = readline()
        if current_game == ""
            printDict("repeat")
            continue
        elseif current_game == "black_jack"
            printDict(("black_jack", 0))
            break
        elseif current_game == "slot_machine"
            printDict(("slot_machine", 0))
            break
        else
            printDict("irritated")
            printDict("repeat")
            continue
        end
    end
    while true
        printDict("spacer")
        if current_game == "black_jack"
            play_black_jack(p)
        elseif current_game == "slot_machine"
            play_slot_machine(p)
        end

        while true
            printDict(("gamble", 2))
            s = readline()
            if s == ""
                printDict("repeat")
                continue
            elseif s == "n"
                printDict(("gamble", 3))
                p.status = reception
                return
            elseif s == "y"
                break
            else
                printDict("irritated")
                printDict("repeat")
                continue
            end
        end
    end
end
function withdraw(p::Player)
    printDict("spacer")
    printDict(("withdraw", 0))
    s = readline()
    amount = tryparse(Int64, s)
    if amount == nothing || amount <= 0
        printDict(("withdraw", 1))
        return
    end
    p.balance += amount

    if p.balance > 10000
        printDict(("withdraw", 2))
        p.balance = 10000
    end
end

function bathroom(p::Player)
    printDict("spacer")
    printDict(("bathroom",0))
    s = readline()
    if s == "w"
        printDict(("bathroom",1))
    elseif s == "l"
        printDict(("bathroom",2))
    else
        printDict(("bathroom",3))
        return
    end

    printDict(("bathroom", 4))

    s = readline()
    if s == "v"
        printDict("spacer")
        use_cryptomat()
    elseif s == "r"
        p.status = reception
    end

    printDict(("bathroom", 5))
end

function receptionDesk(p::Player)
    printDict("spacer")
    printBalance(p.balance)
    printDict(("reception", 0))
    s = readline()
    if s == ""
        printDict(("reception", 1))
    elseif s == "g"
        p.status = gambling
    elseif s == "w"
        withdraw(p)
    elseif s == "b"
        printDict(("reception", 2))
        bathroom(p)
    elseif s == "l"
        exit(0)
    end
end

function main()
    p = Player(0,reception)
    printDict("spacer")
    printDict("welcome")
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

main()
