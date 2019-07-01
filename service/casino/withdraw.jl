function withdraw(p::Player)
    print_dict(p, "spacer")
    print_dict(p, "withdraw_0")
    s = readline(p.socket)
    amount = tryparse(Int64, s)
    if amount == nothing || amount <= 0
        print_dict(p, "withdraw_1")
        return
    end
    if captcha(p, rand(5:10))
        print_dict(p, "withdraw_4")
    else
        print_dict(p, "withdraw_5")
        if captcha(p, rand(5:10))
            print_dict(p, "withdraw_4")
        else
            print_dict(p, "withdraw_6")
            return
        end
    end

    p.balance += amount

    if p.balance > 10000
        print_dict(p, "withdraw_2")
        p.balance = 10000
    end
end

function captcha(p::Player, num)
    print_dict(p, "withdraw_3")
    print_dict(p, "spacer")
    cards = []
    sum = let sum, suits
        sum = 0
        suits = ["♠", "♥", "♦", "♣"]
        for i in 1:num
            x = rand(1:14)
            sum += x
            if (x == 10) x = "T" end
            if (x == 11) x = "J" end
            if (x == 12) x = "Q" end
            if (x == 13) x = "K" end
            if (x == 14) x = "A" end
            y = rand(suits)
            card = """
            ┌─────────┐
            │$(x) $(y)   $(y)  │
            │         │
            │ $(y)     $(y) │
            │    $(x)    │
            │ $(y)     $(y) │
            │         │
            │  $(y)   $(y) $(x)│
            └─────────┘"""
            card = split(card, "\n")
            push!(cards, card)
        end
        sum
    end
    result = let result, offset
        result = ["","","","","","","","","","","","","","",""]
        offset = rand(1:7)
        for card in cards
            for i in 1:offset-1
                result[i] *= "           "
            end
            for i in offset+9:15
                result[i] *= "           "
            end
            i = offset
            for line in card
                result[i] *= line
                i += 1
            end

            offset = ((offset + rand(-2:2)) % 7)
            if offset < 1
                offset = 1
            end
        end
        join(result, "\n")
    end
    write(p.socket, "$result\n")
    print_dict(p, "spacer")
    
    s = readline(p.socket)
    return sum == tryparse(Int, s)
end
