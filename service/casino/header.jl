using Sockets
using Base.Threads

@enum Status reception gambling
@enum Game black_jack slot_machine roulette

mutex_dict = Dict()

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
    global mutex_dict
    if !haskey(mutex_dict, path)
        mutex_dict[path] = Mutex()
    end
    lock(mutex_dict[path])
    f = open(path, mode)
    unlock(mutex_dict[path])
    return f
end
