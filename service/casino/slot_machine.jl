function play_slot_machine(p::Player)
    bet = 0
    print_dict(p, "slot_machine_0")

    while true
        s = readline(p.socket)
        if s == ""
            p.status = reception
            return
        elseif s == "50" && p.balance >= 50
            bet = 50
            break
        elseif s == "10" && p.balance >= 10
            bet = 10
            break
        elseif s == "5"
            if p.balance < 5
                print_dict(p, "slot_machine_1")
                bet = 1
            else
                bet = 5
            end
            break
        else
            print_dict(p, "slot_machine_2")
        end
    end

    print_dict(p, "slot_machine_3")

    if rand(1:10) == 10
        print_dict(p, "slot_machine_4")
        p.balance += bet
    else
        print_dict(p, "slot_machine_5")
        p.balance -= bet
    end

    if p.balance < 0
        print_dict(p, "debt_0")
        p.status = reception
    end
end
