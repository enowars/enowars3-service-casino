import JSON
using Sockets
include("header.jl")

dictionary = open("data/strings.json", "r") do f
    s = read(f, String)
    JSON.parse(s)
end

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
