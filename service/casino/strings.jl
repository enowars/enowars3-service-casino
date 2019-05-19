import JSON
include("header.jl")

dictionary = open("data/strings.json", "r") do f
    s = read(f, String)
    JSON.parse(s)
end
#=dictionary = Dict(
    "spacer" => "****************************",
    "welcome" => "You enter the Casino. It feels like another world. No smog, no dying people hiding behind blankets, just a man smiling at you from the reception.\nYou approach the man...\nWelcome to the great Casino! Leave the rest of the world behind you and enjoy your stay!",
    "walk" => "You just walk away..",
    "repeat" => "Thinking you did not understand they repeat themself..",
    "irritated" => "People start awkwardly looking at you. After a moment has passed they turn their heads back to their games.. Just another crazy person.",
    "dealer" => "You approach one of the black_jack tables. The dealer smiles at you, slightly nods his head as a greeting.",
    "reception_0" => "Do you want to play a game[g], withdraw money[w] or leave[l]?",
    "reception_1" => "The man behind the reception looks slightly irritated and repeats himself..",
    "reception_2" => "You want to use the bathroom? No problem, you can find it down the hall to the left.",
    "bathroom_0" => "You head down the hall and turn left.. On your way you see an old vending machine looking really odd in this fancy casino.\nYou fulfill your duty on the toilet. You can either wash[w] you hands or leave[l] the bathroom.",
    "bathroom_1" => "A feeling of accomplishment comes over you. As you leave the bathroom you realise that people of all genders glance at you in arousal.",
    "bathroom_2" => "You sneak out of the bathroom without being noticed.. You feel like a dirtbag.",
    "bathroom_3" => "Since you like to be edgy, you decide not to decide! For a moment you feel strong and powerful but then you realise that no one cares and you return to the reception..",
    "bathroom_4" => "On your way back to the reception you see the old vending machine again. Do you want to take a closer look at the vending machine[v] or do you want return to the reception[r]?",
    "bathroom_5" => "You return to the reception..",
    "withdraw_0" => "How much money do you want to withdraw?",
    "withdraw_1" => "Sorry there must be some mistake with your credit card...",
    "withdraw_2" => "Sorry you are not allowed to start with more than 10000 chips",
    "gamble_0" => "We offer a variance of games you can choose from:",
    "gamble_1" => "Just name the game and you can start playing!",
    "gamble_2" => "Do you want to play again? [y/n]",
    "gamble_3" => "Alright, see you soon!",
    "gamble_4" => "You leave and head back to the reception..",
    "table_0" => "You can choose to join[j] one of the other tables or create[c] a new one.",
    "table_1" => "Following tables are currently open..",
    "table_2" => "At which table do you want to play? Or do you want to leave[l]?",
    "table_3" => "Sorry there is currently no table open that is in your caliber.",
    "table_4" => "Unless you know the secret passphrase for this table, you are not allowed to play at that table..",
    "table_5" => "Sorry, this was not the secret passphrase..",
    "table_6" => "Choose a name for your table..",
    "table_7" => "Sorry that name is too long..",
    "table_8" => "Choose a minimum limit of chips any player at the table should have..",
    "table_9" => "Sorry the minimum should be at least 0 chips..",
    "table_10" => "Choose a passphrase for the table..",
    "table_11" => "Sorry that passphrase is too long..",
    "table_12" => "Choose an identifier for your table..",
    "table_13" => "Sorry that identifier is too long..",
    "table_14" => "Sorry that identifier has already been taken..",
    "table_15" => "You succesfully created a new table!",
    "slot_machine_0" => "You join many others mindlessly looking at blinking screens.."
)=#

function print_dict(key)
    println(dictionary[key])
end

function printBalance(p::Player)
    println("Your balance is: ", p.balance)
end

function printGames()
    for game in instances(Game)
        println(game)
    end
end
