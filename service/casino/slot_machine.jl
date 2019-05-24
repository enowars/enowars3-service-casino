function play_slot_machine(p::Player)
    bet = 0
    write(p.socket, "You approach the slot_machine. You can throw in [5], [10] or [50] chips.\n")

    while true
        s = readline(p.socket)
        if s == ""
            write(p.socket, "You decide to leave and head back to the reception..\n")
            return
        elseif s == "50" && p.balance >= 50
            bet = 50
            break
        elseif s == "10" && p.balance >= 10
            bet = 10
            break
        elseif s == "5"
            if p.balance < 5
                println("test")
                write(p.socket, "Some weird slightly off looking person comes over to you and looks at you with pity..\n")
                write(p.socket, "You don't even have 5 chips to play at the slot_machine? Here I will help you out..\n")
                write(p.socket, "Even though they left already, their stench still stays with you and reminds you of outside.\n")
                write(p.socket, "You realised that they somehow managed to put one of your chips that you didn't even know that they still existed in the slot_machine.\n")
                bet = 1
            else
                bet = 5
            end
            break
        else
            write(p.socket, "Something seems to be wrong with your chips. Try again..\n")
        end
    end

    write(p.socket, "The slot_machine starts blinking and making noises. You have no idea what is happening..\n")
    if rand(1:10) == 10
        write(p.socket, "You win! What a rush!\n")
        p.balance += bet
    else
        write(p.socket, "What bad luck, you lost..\n")
        p.balance -= bet
    end
end
