using Random

@enum Status counter gambling
@enum Game black_jack slot_machine

mutable struct Player
    balance :: Int64
    status :: Status
end
#### black_jack ####
function play_black_jack(p::Player)

    function total_value(hand)
        total = 0
        aces = 0
        for card in hand
            if card == 14
                aces += 1
                total += 11
            elseif card > 10
                total += 10
            else
                total += card
            end
        end

        for i in 1:aces
            if(total > 21)
                total -= 10
            end
        end
        return total
    end
    function show_cards(hand, all = true)
        s = "** "
        if !all && size(hand,1) > 0
            if hand[1] == 11 s *= "Jack"
            elseif hand[1] == 12 s *= "Queen"
            elseif hand[1] == 13 s *= "King"
            elseif hand[1] == 14 s *= "Ace"
            else
                s = string(s, hand[1])
            end
            return s * " **"
        end
        for card in hand
            if card == 11 s *= "Jack"
            elseif card == 12 s *= "Queen"
            elseif card == 13 s *= "King"
            elseif card == 14 s *= "Ace"
            else
                s = string(s, card)
            end
            s *= " "
        end
        return string(s, "** ", "with a total sum of ", total_value(hand), "")
    end
    function hit(hand, deck)
        append!(hand, pop!(deck))
    end
    function natural(dealer_hand, player_hand)
        dealer_total = total_value(dealer_hand)
        player_total = total_value(player_hand)

        if size(player_hand,1) == 2 && size(dealer_hand,1) == 2
            if player_total == 21 && dealer_total == 21
                println("Both you and the dealer have a black_jack! Congratulations!")
                return true
            elseif player_total == 21
                println("You have a black_jack! Congratulations!")
                return true
            elseif dealer_total == 21
                println("The dealer has a black_jack! Better luck next time!")
                return true
            end
        end
        return false
    end

    function evaluate(dealer_hand, player_hand)
        dealer_total = total_value(dealer_hand)
        player_total = total_value(player_hand)

        if dealer_total > player_total
            println("The dealer wins with ", show_cards(dealer_hand), " against your ", show_cards(player_hand), ". Better luck next time!")
        elseif dealer_total < player_total
            println("You win with ", show_cards(player_hand), " against the dealers ", show_cards(dealer_hand), ". Congratulations!")
        else
            println("A standoff! The dealers ", show_cards(dealer_hand), " against your ", show_cards(player_hand), ".")
        end
    end

    deck = repeat(collect(Int8, 2:14),4)

    shuffle!(deck)
    dealer_hand = [pop!(deck), pop!(deck)]
    player_hand = [pop!(deck), pop!(deck)]

    println("The dealer shows: ", show_cards(dealer_hand, false), ".")
    println("You hold: ",show_cards(player_hand), ".")

    if natural(dealer_hand, player_hand)
        return
    end

    choice = "s"
    println("Do you want to hit[h] or stand[s]?")
    choice = readline()
    while choice != "s"
        if choice == "h"
            hit(player_hand, deck)
            println("You now hold: ",show_cards(player_hand))
            if(total_value(player_hand) > 21)
                println("You busted.. Better luck next time!")
                return
            end
        else
            println("Pardon me, could you repeat that please?")
        end

        println("Do you want to hit[h] or stand[s]?")
        choice = readline()
    end
    println("You decided to stand, the dealer continues their play..")

    println("The dealer shows: ", show_cards(dealer_hand))
    dealer_total = total_value(dealer_hand)
    while dealer_total < 17
        hit(dealer_hand, deck)
        println("The dealer shows: ", show_cards(dealer_hand))
        dealer_total = total_value(dealer_hand)
        if dealer_total > 21
            println("The dealer busted.. Congratulations!")
            return
        end
    end
    evaluate(dealer_hand, player_hand)
end

#### slot_machine ####
function play_slot_machine(p::Player)
    bet = 0
    println("You approach the slot_machine. You can throw in [5], [10] or [50] chips.")

    while true
        s = readline()
        if s == ""
            println("You decide to leave and head back to the counter..")
            return
        elseif s == "50" && p.balance >= 50
            bet = 50
            break
        elseif s == "10" && p.balance >= 10
            bet = 10
            break
        elseif s == "5"
            if p.balance < 5
                println("Some weird slightly off looking person comes over to you and looks at you with pity..")
                println("You don't even have 5 chips to play at the slot_machine? Here I will help you out..")
                println("Even though they left already, their stench still stays with you and reminds you of outside.")
                println("You realised that they somehow managed to put one of your chips that you didn't even know that they still existed in the slot_machine.")
                bet = 1
            else
                bet = 5
            end
            break
        else
            println("Something seems to be wrong with your chips. Try again..")
        end
    end

    println("The slot_machine starts blinking and making noises. You have no idea what is happening..")
    if rand(1:10) == 10
        println("You win! What a rush!")
        p.balance += bet
    else
        println("What bad luck, you lost..")
        p.balance -= bet
    end
end

function printWelcome()
    println("You enter the Casino. It feels like another world. No smog, no dying people hiding behind blankets, just a man smiling at you from the counter.")
    println("You approach the man...")
    println("Welcome to the great Casino! Leave the rest of the world behind you and enjoy your stay!")
end
function gamble(p::Player)
    println("We offer a variance of games you can choose from:")
    #foreach(x -> println(x), games)
    for game in instances(Game)
        println(game)
    end
    println("Just name the game and you can start playing!")
    current_game = ""
    while true
        current_game = readline()
        if current_game == ""
            println("Thinking you did not understand they repeat themself..")
            return
        elseif current_game == "black_jack"
            println("You approach one of the black_jack tables. The dealer smiles at you, slightly nods his head as a greeting and starts dealing cards.")
            break
        elseif current_game == "slot_machine"
            println("You join many others mindlessly looking at blinking screens..")
            break
        else
            println("Pardon me, could you repeat that please?")
        end
    end
    while true
        if current_game == "black_jack"
            play_black_jack(p)
        elseif current_game == "slot_machine"
            play_slot_machine(p)
        end

        while true
            println("Do you want to play again? [y/n]")
            s = readline()
            if s == ""
                println("You awkwardly just keep the question unanswered and go back to the counter..")
                p.status = counter
                return
            elseif s == "n"
                println("Alright, see you soon!")
                p.status = counter
                return
            elseif s == "y"
                break
            else
                println("Pardon me, could you repeat that please?")
            end
        end
    end
end
function withdraw(p::Player)
    println("How much money do you want to withdraw?")
    s = readline()
    withdrawal = tryparse(Int64, s)
    if withdrawal == nothing || withdrawal <= 0
        println("Sorry there must be some mistake with your credit card...")
        return
    end
    p.balance += withdrawal

    if p.balance > 10000
        println("Thanks for the tip! You tipped: ", p.balance - 10000, "...")
        p.balance = 10000
    end
    println("Your new balance is: ", p.balance)
end

function printCounter(p::Player)
    println("Your current balance is: ", p.balance)
    println("Do you want to play a game[g], withdraw money[w] or leave[l]?")
    s = readline()
    if s == ""
        println("The man behind the counter looks slightly irritated and repeats himself..")
    elseif s == "g"
        p.status = gambling
    elseif s == "w"
        withdraw(p)
    elseif s == "l"
        exit(0)
    end
end

function main()
    p = Player(0,counter)
    printWelcome()
    while true
        if p.status == counter
            printCounter(p)
        elseif p.status == gambling
            gamble(p)
        end
    end
end
####################################
####################################

main()
