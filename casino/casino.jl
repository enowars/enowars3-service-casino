@enum Status counter withdrawal
mutable struct Player
    balance :: Int
    status :: Status
end
games = ["Black Jack"]

function printWelcome(p::Player)
    println("You entered the Casino. It feels like another world. No smog, no dying people hiding behind blankets, just a man smiling at you from the counter.")
    println("You approach the man...")
    println("Welcome to the great Casino! Leave the rest of the world behind you and enjoy your stay!")
end
function printGames(p::Player)
    println("We offer a variance of games you can choose from:")
    foreach(x -> println(x), games)
end
function withdraw(p::Player)
    println("How much money do you want to withdraw?")
    s = readline()
    withdrawal = parse(Int, s)
    p.balance = p.balance + withdrawal

    if(p.balance > 10000)
        println("Thanks for the tip! You tipped: ", p.balance - 10000, "...")
        p.balance = 10000
    end
    println("Your new balance is: ", p.balance)


end
function closeConnection(p::Player)
    println("Not implemented!")
end
function printCounter(p::Player)
    println("Your current balance is: ", p.balance)
    println("Do you want to play a game[g], leave[l] or withdraw money[w]?")
    s = readline()
    if(s[1] == 'g')
        printGames(p)
    elseif s[1] == 'l'
        closeConnection(p)
    elseif s[1] == 'w'
        withdraw(p)
    end
end

function main()
    p = Player(0,counter)
    printWelcome(p)
    while(true)
        if(p.status == counter)
            printCounter(p)
        elseif(p.status == withdrawal)
            withdraw(p)
        end

        break

    end
end
####################################
####################################

main()
