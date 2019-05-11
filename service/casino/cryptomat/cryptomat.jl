include("sender.jl")


function printMenu()
println("""
        Welcome to the Cryptomat!

        Choose your mode:
            [1] AES CBC
            [2] AES CFB
            [3] AES CTR
            [4] AES ECB
            [5] AES OFB
            [r] print this message
            [l] leave
        """)
end



function use_cryptomat()
    printMenu()

    while true
        user_input = readline()
        if ("1" <= user_input <= "5")
            sendSecret(parse(Int, user_input))
            printMenu()
        elseif user_input == "r"
            printMenu()
            continue
        elseif user_input == "l"
            break
        else
            println("Invalid input")
        end
    end
    println("Goodbye. Your Cryptomat")
end