include("header.jl")
dictionary = Dict(
    "welcome" => "You enter the Casino. It feels like another world. No smog, no dying people hiding behind blankets, just a man smiling at you from the reception.\nYou approach the man...\nWelcome to the great Casino! Leave the rest of the world behind you and enjoy your stay!",
    "walk" => "You just walk away..",
    "repeat" => "Thinking you did not understand they repeat themself..",
    "irritated" => "People start awkwardly looking at you. After a moment has passed they turn their heads back to their games.. Just another crazy person.",
    ("reception", 0) => "Do you want to play a game[g], withdraw money[w] or leave[l]?",
    ("reception", 1) => "The man behind the reception looks slightly irritated and repeats himself..",
    ("withdraw", 0) => "How much money do you want to withdraw?",
    ("withdraw", 1) => "Sorry there must be some mistake with your credit card...",
    ("withdraw", 2) => "Sorry you are not allowed to start with more than 10000 chips",
    ("gamble", 0) => "We offer a variance of games you can choose from:",
    ("gamble", 1) => "Just name the game and you can start playing!",
    ("gamble", 2) => "Do you want to play again? [y/n]",
    ("gamble", 3) => "Alright, see you soon!",
    ("black_jack", 0) => "You approach one of the black_jack tables. The dealer smiles at you, slightly nods his head as a greeting and starts dealing cards.",
    ("slot_machine", 0) => "You join many others mindlessly looking at blinking screens.."

)

function printDict(key)
    println(dictionary[key])
end

function printBalance(balance)
    println("Your balance is: ", balance)
end

function printGames()
    for game in instances(Game)
        println(game)
    end
end
