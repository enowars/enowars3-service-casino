function withdraw(p::Player)
    print_dict(p, "spacer")
    print_dict(p, "withdraw_0")
    s = readline(p.socket)
    amount = tryparse(Int64, s)
    if amount == nothing || amount <= 0
        print_dict(p, "withdraw_1")
        return
    end
    p.balance += amount

    if p.balance > 10000
        print_dict(p, "withdraw_2")
        p.balance = 10000
    end
end

function captcha(p::Player, num)
    print_dict(p, "withdraw_3")

    return true
end
