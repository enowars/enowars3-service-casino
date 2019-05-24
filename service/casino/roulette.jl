using Sockets
include("header.jl")
include("strings.jl")

function play_roulette(p :: Player)
    result = rand(1:36)
    total_bet = 0
    winnings = 0
    write(p.socket, "Place your bets!\n")
    printBalance(p)
    write(p.socket, """As you have no idea what you should do you wait for others to place their bets..\nSome old lady says: "100 red" and the dealer responds 100 chips on red.\nSomeone else says: "1500 13-24" and the dealer responds 1500 chips on the numbers from 13 to 24.\n""")
    while true
        write(p.socket, "Place your bets or tell me when you are done[d]..\n")
        s = readline(p.socket)
        lines = split(s)
        if s == ""
            continue
        elseif s == "d"
            if total_bet > 0
                break
            else
                write(p.socket, "Sorry but this is not a childs game. You can leave now.\n")
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
                write(p.socket, "I am really sorry but you do not have that many chips left..\n")
                continue
            elseif bet == 0
                write(p.socket, "Sorry but this is not a childs game. You can leave now.\n")
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

    write(p.socket, "The ball starts jumping up and down in the wheel, you tremble with excitement..\n")
    write(p.socket, "After a few rotations the ball stays in a slot..\n")
    write(p.socket, "Congratulations the number is.. $result. Your total winnings are: $winnings\n")

    p.balance += winnings
end
