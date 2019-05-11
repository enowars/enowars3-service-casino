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

function play_black_jack(p::Player)
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
