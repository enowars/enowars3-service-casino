function play_slot_machine(p::Player)
    bet = 0
    println("You approach the slot_machine. You can throw in [5], [10] or [50] chips.")

    while true
        s = readline()
        if s == ""
            println("You decide to leave and head back to the reception..")
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
