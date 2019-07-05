import JSON
using Sockets
include("header.jl")

f = open_file_try("data/strings.json", "r")
s = read(f, String)
dictionary = JSON.parse(s)


function print_dict(p, key)
    write(p.socket, "$(dictionary[key])\n")
end

function printBalance(p::Player)
    write(p.socket, "Your balance is: $(p.balance)\n")
end

function printGames(p::Player)
    for game in instances(Game)
        write(p.socket, "$game\n")
    end
end
