using Random

@enum Status counter gaming
@enum Game black_jack

mutable struct Player
    balance :: Int32
    status :: Status
    game :: Game
end
#### black_jack ####
function play_black_jack(p::Player)

    function total(hand)
        total = 0
        for card in hand
            if(card == 14 && total >= 11)
                total += 1
            elseif(card == 14)
                total += 11
            elseif(card > 10)
                total += 10
            else
                total += card
            end
        end
        return total
    end
    function show_cards(hand, all = true)
        s = "** "
        if(!all && size(hand,1) > 0)
            if(hand[1] == 11) s *= "Jack"
            elseif(hand[1] == 12) s *= "Queen"
            elseif(hand[1] == 13) s *= "King"
            elseif(hand[1] == 14) s *= "Ace"
            else
                s = string(s, hand[1])
            end
            return s * " **"
        end
        for card in hand
            if(card == 11) s *= "Jack"
            elseif(card == 12) s *= "Queen"
            elseif(card == 13) s *= "King"
            elseif(card == 14) s *= "Ace"
            elseif(true)
                s = string(s, card)
            end
            s *= " "
        end
        return string(s, "** ", "with a total sum of ", total(hand), ".\n")
    end
    deck = repeat(collect(Int8, 2:14),4)

    shuffle!(deck)
    dealer_hand = [pop!(deck), pop!(deck)]
    player_hand = [pop!(deck), pop!(deck)]

    println("The dealer shows: ", show_cards(dealer_hand, false))
    println("You hold: ",show_cards(player_hand))


end



function printWelcome(p::Player)
    println("You enter the Casino. It feels like another world. No smog, no dying people hiding behind blankets, just a man smiling at you from the counter.")
    println("You approach the man...")
    println("Welcome to the great Casino! Leave the rest of the world behind you and enjoy your stay!")
end
function printGames(p::Player)
    println("We offer a variance of games you can choose from:")
    #foreach(x -> println(x), games)
    for game in instances(Game)
        println(game)
    end
end
function withdraw(p::Player)
    println("How much money do you want to withdraw?")
    s = readline()
    withdrawal = tryparse(Int32, s)
    if(withdrawal == nothing || withdrawal <= 0)
        println("Sorry there must be some mistake with your credit card...")
        return
    end
    p.balance += withdrawal

    if(p.balance > 10000)
        println("Thanks for the tip! You tipped: ", p.balance - 10000, "...")
        p.balance = 10000
    end
    println("Your new balance is: ", p.balance)


end
function printCounter(p::Player)
    println("Your current balance is: ", p.balance)
    println("Do you want to play a game[g], withdraw money[w] or leave[l]?")
    s = readline()
    if(s[1] == 'g')
        printGames(p)
    elseif s[1] == 'w'
        withdraw(p)
    elseif s[1] == 'l'
        exit()
    end
end

function main()
    p = Player(0,counter,black_jack)
    printWelcome(p)
    while(true)
        if(p.status == counter)
            printCounter(p)
        elseif(p.status == gaming)

        end
    end
end
####################################
####################################

#main()
