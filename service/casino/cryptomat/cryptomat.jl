include("sender.jl")
include("os_updater.jl")


function printMenu()
println("""
        Welcome to the Cryptomat!

        Choose your mode:
            [1 ١] AES CBC
            [2 ٢] AES CFB
            [3 ٣] AES CTR
            [4 ٤] AES ECB
            [5 ٥] AES OFB
            [u] Upload message
            [c] clear message
            [o] OS update
            [r] Print this message
            [l] Leave
        """)
end



function use_cryptomat()
    printMenu()
    global note_max_length = 2
    global msg = ""
    while true
        user_input = readline()
        if ("1" <= user_input <= "5") || ("١" <= user_input <= "٥")
            sendSecret(parse(Int, user_input), msg)
            printMenu()
        elseif user_input == "u"
            println("Enter your message:")
            msg = readline()
            printMenu()
        elseif user_input == "c"
            msg = ""
        elseif user_input == "r"
            printMenu()
            continue
        elseif user_input == "o"
            updateOS()
            printMenu()
        elseif user_input == "l"
            break
        elseif user_input == "◈"
            if !(isfile("data/.note"))
                println("The crpytomat feels cold.")
            else
                println("You find a sparkling note under the Cryptomat.")
                f = open("data/.note", "r")
                println(JSON.parse(read(f, String)))
                close(f)
            end
        elseif user_input == "🕐"
            update = readline()
            try
                global dimension = parse(Int, update)
            catch
                continue
            end
        else
            println("Invalid input")
        end
    end
    println("Goodbye. Your Cryptomat")
end
