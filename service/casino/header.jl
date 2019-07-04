using Sockets

@enum Status reception gambling
@enum Game black_jack slot_machine roulette

mutable struct Player
    balance :: Int64
    status :: Status
    current_game :: Game
    socket :: TCPSocket
    dimension :: Int
    msg :: String
    token :: String
    diarrhea :: Bool
end

#julia + async + docker makes some problems...
#therefore we try to open the file several times
function open_file_try(path, mode, max_trys=5)
    for i = 1:max_trys+1
        try
            f = open(path, mode)
            return f
        catch err
            if i == max_trys
                throw(err)
            else
                sleep(0.05)
            end
        end
end
