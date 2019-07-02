using Sockets
include("header.jl")
include("strings.jl")

function play_roulette(p :: Player)
    result = rand(1:36)
    total_bet = 0
    winnings = 0
    print_dict(p, "roulette_0")
    printBalance(p)
    print_dict(p, "roulette_1")
    while true
        print_dict(p, "roulette_2")
        s = readline(p.socket)
        lines = split(s)
        if s == ""
            continue
        elseif s == "d"
            if total_bet > 0
                break
            else
                print_dict(p, "roulette_3")
                p.status = reception
                return
            end
        elseif size(lines,1) != 2
            print_dict(p, "repeat")
            continue
        else
            bet = tryparse(Int64, lines[1])

            if bet == nothing || bet < 0
                print_dict(p, "repeat")
                continue
            elseif bet > (p.balance - total_bet)
                print_dict(p, "roulette_4")
                continue
            elseif bet == 0
                print_dict(p, "roulette_3")
                p.status = reception
                return
            end

            number = tryparse(Int, lines[2])

            if number == nothing
                if lines[2] == "red"
                    if (result < 19 && result % 2 == 1) || (result > 19 && result % 2 == 0)
                        winnings += bet
                    else
                        winnings -= bet
                    end
                    total_bet += bet
                    continue
                elseif lines[2] == "black"
                    if (result < 19 && result % 2 == 0) || (result > 19 && result % 2 == 1)
                        winnings += bet
                    else
                        winnings -= bet
                    end
                    total_bet += bet
                    continue
                elseif lines[2] == "1-12"
                    if result <= 12
                        winnings += 3 * bet
                    else
                        winnings -= bet
                    end
                    total_bet += bet
                    continue
                elseif lines[2] == "13-24"
                    if result > 12 && result <= 24
                        winnings += 3 * bet
                    else
                        winnings -= bet
                    end
                    total_bet += bet
                    continue
                elseif lines[2] == "25-36"
                    if result > 24 && result <= 36
                        winnings += 3 * bet
                    else
                        winnings -= bet
                    end
                    total_bet += bet
                    continue
                else
                    print_dict(p, "repeat")
                    continue
                end
            elseif number >= 1 && number <= 36
                if number == result
                    winnings += 36 * bet
                else
                    winnings -= bet
                end

                total_bet += bet
                continue
            else
                print_dict(p, "repeat")
                continue
            end


        end
    end

    print_dict(p, "roulette_5")
    write(p.socket, "Congratulations the number is.. $result. Your total winnings are: $winnings\n")

    p.balance += winnings
end
